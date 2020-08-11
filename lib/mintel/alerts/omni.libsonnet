{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'omni.alerts',
        rules: [
          {
            alert: 'OmniHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: 95th percentile of response times is more than 5s on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_request_seconds_quantile:95{mintel_com_service=~".*omni-web"} > 5',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'OmniHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: 95th percentile of response times is more than 10s on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_request_seconds_quantile:95{mintel_com_service=~".*omni-web"} > 10',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
