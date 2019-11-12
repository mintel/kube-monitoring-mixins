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
            },
            expr: 'count(mintel:web_frontend:check_up) by (job, namespace, service) == 0',
            'for': '1m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ReducedService',
            annotations: {
              description: 'Service `{{$labels.service}}`is down.',
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
