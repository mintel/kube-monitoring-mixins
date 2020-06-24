{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'redis-spotahome-operator.alerts',
        rules: [
          {
            alert: 'RedisOperatorClusterNotOK',
            expr: 'redis_operator_controller_cluster_ok == 0',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'The Redis operator has detected an error with a cluster',
              description: 'The Redis operator has detected that the {{ $labels.name }} cluster is not ok',
            },
          },
          {
            alert: 'RedisOperatorRequeue',
            expr: 'increase(kooper_controller_queued_events_total{type="requeue"}[5m]) > 5',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'The Redis operator is requeueing events at a high rate',
              description: 'The Redis operator is requeueing events at a high rate. This is usually indicative of an error in its reconciliation loop',
            },
          },
          {
            alert: 'RedisOperatorErrors',
            expr: 'increase(kooper_controller_processed_event_errors_total[5m]) > 5',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'The Redis operator is experiencing errors',
              description: 'The Redis operator is experiencing errors',
            },
          },
        ],
      },
    ],
  },
}
