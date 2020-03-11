{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mysql.alerts',
        rules: [
          {
            alert: 'MySQLThreadConnections',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/MySQL.md#MySQLThreadConnections' % $._config,
              summary: 'MySQL: There are no threads connected to the database monitored by {{ $labels.service }}',
            },
            expr: 'mysql_global_status_threads_connected == 0',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'MySQLThreadConnections',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/MySQL.md#MySQLThreadConnections' % $._config,
              summary: 'MySQL: There are no threads connected to the database monitored by {{ $labels.service }}',
            },
            expr: 'mysql_global_status_threads_connected == 0',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'MySQLMaxUsedConnections',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/MySQL.md#MySQLMaxUsedConnections' % $._config,
              summary: 'MySQL: Max no. of connections for database monitored by {{ $labels.service }} is approaching the limit for a db-n1-standard-1 instance',
            },
            expr: 'mysql_global_status_max_used_connections > 3600',
            'for': '1m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'MySQLAbortedConnections',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/MySQL.md#MySQLAbortedConnections' % $._config,
              summary: 'MySQL: No. of aborted connections continuously increasing for database monitored by {{ $labels.service }}',
            },
            expr: 'increase(mysql_global_status_aborted_connects[1m]) > 3',
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
