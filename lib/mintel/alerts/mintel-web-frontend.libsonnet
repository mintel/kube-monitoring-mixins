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
            expr: 'count(mintel:web_frontend:check_up == 1) by (job, namespace, service, environment, label_app_mintel_com_owner) == 0',
            'for': '3m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'MintelWebServiceDown',
            annotations: {
              description: 'Service `{{$labels.service}}`is down.',
              runbook_url: '%(runBookBaseURL)s/core/MintelWebServiceDown.md' % $._config,
            },
            expr: 'count(mintel:web_frontend:check_up == 1) by (job, namespace, service, environment, label_app_mintel_com_owner) == 0',
            'for': '1m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'MintelReducedService',
            annotations: {
              description: 'Service `{{$labels.service}}`is down.',
              runbook_url: '%(runBookBaseURL)s/core/MintelReducedService.md' % $._config,
            },
            expr: 'count(mintel:web_frontend:check_up == 1) by (job, namespace, service, environment, label_app_mintel_com_owner) == 1',
            'for': '3m',
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
            expr: 'count(mintel:web_frontend:check_up == 1) by (job, namespace, service, environment, label_app_mintel_com_owner) == 1',
            'for': '1m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
