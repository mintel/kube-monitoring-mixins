{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'redis.alerts',
        rules: [
          {
            alert: 'RedisMaxMemoryUnset',
            expr: 'redis_memory_max_bytes <= 0',
            'for': '5m',
            labels: {
              severity: 'warning'
            },
            annotations: {
              summary: 'Redis instance has non max-memory set',
              description: 'The redis instance {{ $labels.service }} has no maximum memory set',
            },
          },
          {
            alert: 'RedisRejectedConnections',
            expr: 'increase(redis_rejected_connections_total[1m]) > 0',
            'for': '10m',
            labels: {
              severity: 'warning'
            },
            annotations: {
              summary: 'Rejected connections (instance {{ $labels.service }})',
              description: 'Some connections to Redis have been rejected each minute for the previous 10 minutes',
            },
          },
          {
            alert: 'RedisTooManyConnections',
            expr: '(redis_connected_clients / redis_config_maxclients  * 100 > 90)',
            'for': '10m',
            labels: {
              severity: 'warning'
            },
            annotations: {
              summary: 'The {{ $labels.service }} Redis instance has reached 90% of its max-allowed connected clients',
              description: 'There are too many connections to redis in the last 10 minutes',
            },
          },
        ],
      },
    ],
  },
}
