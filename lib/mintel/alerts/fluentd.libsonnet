{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'fluentd.alerts',
        rules: [
          {
            alert: 'FluentdHighOutputRetry',
            annotations: {
              description: 'Fluentd number of output retry has been increasing for 1h',
              summary: 'Fluentd number of output retry has been increasing for 1h',
              runbook_url: '%(runBookBaseURL)s/core/FluentdHighOutputRetry.md' % $._config,
            },
            expr: 'sum by (service,pod,type) (increase(fluentd_output_status_retry_count{type!~"^(null|rewrite_tag_filter|detect_exceptions)$"}[5m])) >0',
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
