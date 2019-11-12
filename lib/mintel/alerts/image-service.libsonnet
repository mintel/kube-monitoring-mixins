{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'image-service.alerts',
        rules: [
          {
            alert: 'ImageServiceAuthIssues',
            annotations: {
              message: 'Service {{ $labels.service }} is returning auth issues fo {{ $value }}% of requests (2% threshold)',
              runbook_url: '%(runBookBaseURL)s/image-service/ImageServiceAuthIssues.md' % $._config,
            },
            expr: 'sum(rate(thumbor_response_status_total{service=~"image-service-.*", statuscode=~"^(403)$"}[5m])) by (service, app_kubernetes_io_owner)\n  /\nsum(rate(thumbor_response_status_total{service=~"image-service-.*"}[5m])) by (service, app_kubernetes_io_owner)\n* 100 > 2\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ImageServiceAuthIssues',
            annotations: {
              message: 'Service {{ $labels.service }} is returning auth issues for {{ $value }}% of requests (5% threshold)',
              runbook_url: '%(runBookBaseURL)s/image-service/ImageServiceAuthIssues.md' % $._config,
            },
            expr: 'sum(rate(thumbor_response_status_total{service=~"image-service-.*", statuscode=~"^(403)$"}[5m])) by (service, app_kubernetes_io_owner)\n  /\nsum(rate(thumbor_response_status_total{service=~"image-service-.*"}[5m])) by (service, app_kubernetes_io_owner)\n* 100 > 5\n',
            'for': '2m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
