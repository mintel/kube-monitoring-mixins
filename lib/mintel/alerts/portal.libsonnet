{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'portal.alerts',
        rules: [
          {
            alert: 'PortalHAProxyBackendResponseTime',
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
            alert: 'PortalHAProxyBackendResponseTime',
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
        ],
      },
    ],
  },
}
