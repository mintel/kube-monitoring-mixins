{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-pod.alerts',
        rules: [{
          alert: 'PodOOMKilled',
          annotations: {
            description: 'Container {{ $labels.container }} in pod {{ $labels.pod }} has been OOMKilled AT LEAST {{ $value }} times in the last hour',
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/PodOOMKilled.md',
            summary: 'Pod is being OOMKilled',
          },
          expr: 'sum_over_time(kube_pod_container_status_terminated_reason{reason="OOMKilled"}[1h]) > 3',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'KubePodFailed',
          annotations: {
            message: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a Failed state for longer than an hour.',
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/KubePodFailed.md',
          },
          expr: 'sum by (namespace, pod) (kube_pod_status_phase{job="kube-state-metrics", phase=~"Failed"}) > 0\n',
          'for': '1h',
          labels: {
            severity: 'critical',
          },
        }],
      },
    ],
  },
}
