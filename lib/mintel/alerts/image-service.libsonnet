{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'image-service.alerts',
        rules: [
          {
            alert: 'ImageServiceHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: Average response times increased on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_response_wait_seconds_bucket:histogram_quantile{label_app_mintel_com_owner="moat", mintel_com_service=~".*image-service.*"} > 5\n',
            'for': '2m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ImageServiceHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: Average response times increased on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_response_wait_seconds_bucket:histogram_quantile{label_app_mintel_com_owner="moat", mintel_com_service=~".*image-service.*"} > 1\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ImageServiceAuthIssues',
            annotations: {
              message: 'Service {{ $labels.service }} is returning auth issues fo {{ $value }}% of requests (2% threshold)',
              runbook_url: '%(runBookBaseURL)s/image-service/ImageServiceAuthIssues.md' % $._config,
            },
            expr: |||
              sum(rate(thumbor_response_status_total{service=~".*image-service.*", statuscode=~"^(403)$"}[5m])) by (service, app_mintel_com_owner)
              /
              sum(rate(thumbor_response_status_total{service=~".*image-service.*"}[5m])) by (service, app_mintel_com_owner)
              * 100 > 2
            |||,
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
            expr: |||
              sum(rate(thumbor_response_status_total{service=~".*image-service.*", statuscode=~"^(403)$"}[5m])) by (service, app_mintel_com_owner)
              /
              sum(rate(thumbor_response_status_total{service=~".*image-service.*"}[5m])) by (service, app_mintel_com_owner)
              * 100 > 5
            |||,
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
