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
            alert: 'KubePodDistributionUnbalancedByNode',
            annotations: {
              description: 'Pod Distribution for: {{ $labels.created_by_kind }}/{{ $labels.created_by_name}} , {{ $value }}% are on node {{ $labels.node }}',
              message: 'Pod Distribution for pods is unbalanced by node',
              runbook_url: '%(runBookBaseURL)s/core/KubePodDistributionUnbalancedByNode.md' % $._config,
            },
            expr: |||
              100 * (
                (count by (created_by_kind, created_by_name, node ) (kube_pod_info{created_by_kind!~"<none>|Job"}) > 1) 
                / 
                ignoring(node) 
                  group_left(created_by_kind, created_by_name) 
                    count by (created_by_kind, created_by_name) (kube_pod_info{created_by_kind!~"<none>|Job"})
              ) > %(kubePodDistributionUnbalancedByNodePercentageThreshold)s
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubePodDistributionUnbalancedByZone',
            annotations: {
              description: 'Pod Distribution for: {{ $labels.created_by_kind }}/{{ $labels.created_by_name}} , {{ $value }}% are in zone {{ $labels.label_failure_domain_beta_kubernetes_io_zone }}',
              message: 'Pod Distribution for pods is unbalanced in the availability zones',
              runbook_url: '%(runBookBaseURL)s/core/KubePodDistributionUnbalancedByZone.md' % $._config,
            },
            expr: |||
              100 * (
                (count by(created_by_kind, created_by_name, label_failure_domain_beta_kubernetes_io_zone) 
                  (kube_pod_info{created_by_kind!~"<none>|Job"} * on(node) 
                   group_left(label_failure_domain_beta_kubernetes_io_zone) kube_node_labels) > 1 )
                / 
                ignoring(label_failure_domain_beta_kubernetes_io_zone) group_left(created_by_kind, created_by_name) 
                  count by(created_by_kind, created_by_name) (kube_pod_info{created_by_kind!~"<none>|Job"})
              ) > %(kubePodDistributionUnbalancedByZonePercentageThreshold)s
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
