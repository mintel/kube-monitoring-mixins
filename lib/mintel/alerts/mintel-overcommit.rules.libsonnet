{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-overcommit.rules.alerts',
        rules: [{
          alert: 'ClusterLowCPUAvailable',
          annotations: {
            description: 'There is only {{ $value }}% allocatable CPU remaining across all cluster nodes',
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/ClusterLowCPUAvailable.md',
            summary: 'Low CPU available across all cluster nodes',
          },
          expr: '100 * sum(node:cpu_cores_for_pod_available:cores{node!~"master.*"}) / sum(node:node_num_cpu:sum{node!~"master.*"}) < 10',
          'for': '30m',
          labels: {
            context: 'cluster',
            severity: 'warning',
          },
        }
                {
          alert: 'ClusterLowMemoryAvailable',
          annotations: {
            description: 'There is only {{ $value }}% allocatable memory remaining across all cluster nodes',
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/ClusterLowMemoryAvailable.md',
            summary: 'Low memory available across all cluster nodes',
          },
          expr: '100 * sum(node:memory_for_pod_available:bytes{node!~"master.*"}) / sum(node:node_memory_bytes_total:sum{node!~"master.*"}) < 10',
          'for': '30m',
          labels: {
            context: 'cluster',
            severity: 'critical',
          },
        }],
      },
    ],
  },
}
