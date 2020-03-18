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
            expr: 'haproxy:http_backend_response_wait_seconds_bucket:histogram_quantile{label_app_mintel_com_owner="portal",mintel_com_service=~".*-portal-web"} > 0.5\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'PortalHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: Average response times increased on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_response_wait_seconds_bucket:histogram_quantile{label_app_mintel_com_owner="portal",mintel_com_service=~".*-portal-web"} > 1\n',
            'for': '30m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
