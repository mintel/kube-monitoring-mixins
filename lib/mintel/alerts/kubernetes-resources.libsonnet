{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'kubernetes-resources-mintel.alerts',
        rules: [
          {
            alert: 'KubeCPUOvercommit',
            annotations: {
              message: 'Cluster has overcommitted CPU resource requests for Namespaces.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuovercommit',
            },
            expr: |||
              sum(kube_resourcequota{%(prefixedNamespaceSelector)s%(kubeStateMetricsSelector)s, type="hard", resource="requests.cpu"})
                /
              sum(node:node_num_cpu:sum)
                > %(quotaVsNodesOvercommitFactor)s
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubeMemOvercommit',
            annotations: {
              message: 'Cluster has overcommitted memory resource requests for Namespaces.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememovercommit',
            },
            expr: |||
              sum(kube_resourcequota{%(prefixedNamespaceSelector)s%(kubeStateMetricsSelector)s, type="hard", resource="requests.memory"})
                /
              sum(node_memory_MemTotal_bytes{%(nodeExporterSelector)s})
                > %(quotaVsNodesOvercommitFactor)s
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubePodDistributionUnbalanced',
            annotations: {
              description: 'Pod Distribution for: {{ $labels.created_by_kind }}/{{ $labels.created_by_name}} , {{ $value }}% are on node {{ $labels.node }}',
              message: 'Pod Distribution for pods is unbalanced',
              runbook_url: '%(runBookBaseURL)s/core/KubePodDistributionUnbalanced.md' % $._config,
            },
            expr: |||
              100 * (
                (count by (created_by_kind, created_by_name, node ) (kube_pod_info{created_by_kind!~"<none>|Job"}) > 1) 
                / 
                ignoring(node) 
                  group_left(created_by_kind, created_by_name) 
                    count by (created_by_kind, created_by_name) (kube_pod_info{created_by_kind!~"<none>|Job"})
              ) > %(kubePodDistributionUnbalancedPercentageThreshold)s
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
