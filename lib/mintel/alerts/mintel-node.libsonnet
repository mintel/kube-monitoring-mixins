{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-node.alerts',
        rules: [{
          alert: 'NetworkErrorRate',
          annotations: {
            description: 'Network interface {{ $labels.device }} on instance {{ $labels.instance }} has {{ $value }} error rate over the last 1m',
            summary: 'Network Interface has high error rate',
          },
          expr: 'instance:node_network_errs:rate > 10',
          'for': '10m',
          labels: {
            context: 'network',
            severity: 'warning',
          },
        }
                {
          alert: 'NetworkDropsRate',
          annotations: {
            description: 'Network interface {{ $labels.device }} on instance {{ $labels.instance }} has {{ $value }} drop rate over the last 1m',
            summary: 'Network Interface has high drop rate',
          },
          expr: 'instance:node_network_drop:rate > 10',
          'for': '10m',
          labels: {
            context: 'network',
            severity: 'warning',
          },
        }
                {
          alert: 'NodeFreeConntrackEntriesLow',
          annotations: {
            description: 'Free Conntrack entries is less than 10% on this node: {{ $labels.instance }} : {{ $value }}%',
            summary: 'Free Conntrack entries is less than 10% on this node',
          },
          expr: 'node:conntrack_entries_free:percentage < 10',
          'for': '20m',
          labels: {
            context: 'node',
            severity: 'critical',
          },
        }],
      },
    ],
  },
}
