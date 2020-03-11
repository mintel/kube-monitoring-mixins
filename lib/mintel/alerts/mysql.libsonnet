{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mysql.alerts',
        rules: [
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
