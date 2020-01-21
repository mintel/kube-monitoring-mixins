{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-pod.alerts',
        rules: [
          {
            alert: 'PodOOMKilled',
            annotations: {
              description: 'Container {{ $labels.container }} in pod {{ $labels.pod }} has been OOMKilled AT LEAST {{ $value }} times in the last hour',
              runbook_url: '%(runBookBaseURL)s/core/PodOOMKilled.md' % $._config,
              summary: 'Pod is being OOMKilled',
            },
            expr: 'sum_over_time(kube_pod_container_status_terminated_reason{reason="OOMKilled"}[1h]) > 3',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'KubePodFailed',
            annotations: {
              message: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a Failed state for longer than an hour.',
              runbook_url: '%(runBookBaseURL)s/core/KubePodFailed.md' % $._config,
            },
            expr: 'sum by (namespace, pod) (kube_pod_status_phase{job="kube-state-metrics", phase=~"Failed"}) > 0\n',
            'for': '1h',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'KubePodImageMismatch',
            annotations: {
              message: 'Workload {{ $labels.namespace }}/{{ $labels.created_by_kind }}/{{ $labels.created_by_name }} has {{ $value }} different image versions running',
              runbook_url: '%(runBookBaseURL)s/core/KubePodImageMismatch.md' % $._config,
            },
            expr: |||
              count(
                count(
                  (kube_pod_container_info) * on(pod)
                  group_left(created_by_kind, created_by_name) (kube_pod_info{created_by_kind!~"<none>|Job"})
                )
                by (created_by_kind, created_by_name, image_id, container, namespace)
              )
              by (created_by_kind, created_by_name, container, namespace)
              > 1
            |||,
            'for': '30m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
