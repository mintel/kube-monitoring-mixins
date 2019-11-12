{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-web-frontend.alerts',
        rules: [
          {
            alert: 'MintelWebServiceDown',
            annotations: {
              description: 'Service `{{$labels.service}}`is down.',
              runbook_url: '%(runBookBaseURL)s/core/MintelWebServiceDown.md' % $._config,
            },
            expr: 'count(mintel:web_frontend:check_up) by (job, namespace, service) == 0',
            'for': '1m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'MintelReducedService',
            annotations: {
              description: 'Service `{{$labels.service}}`is down.',
              runbook_url: '%(runBookBaseURL)s/core/MintelReducedService.md' % $._config,
            },
            expr: 'count(mintel:web_frontend:check_up) by (job, namespace, service) == 1',
            'for': '1m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
