{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'haproxy-ingress.alerts',
        rules: [
          {
            alert: 'HAProxyFrontendSessionUsage',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendSessionUsage' % $._config,
              summary: 'HAProxy: Session usage on {{ $labels.frontend }} frontend has reached {{ $value }}%',
            },
            expr: 'haproxy:http_frontend_session_usage:percentage >= 80',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyFrontendSessionUsage',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendSessionUsage' % $._config,
              summary: 'HAProxy: Session usage on {{ $labels.frontend }} frontend has reached {{ $value }}%',
            },
            'for': '15m',
            expr: 'haproxy:http_frontend_session_usage:percentage >= 90',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyFrontendSessionUsageWillRunOut',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendSessionUsage' % $._config,
              summary: 'HAProxy: Session usage on {{ $labels.frontend }} frontend has reached {{ $value }}% and will run out in the next 2h',
            },
            expr: |||
              haproxy:http_frontend_session_usage:percentage >= 90 
              and
              predict_linear(haproxy:http_frontend_session_usage:percentage[1h], 2*60*60) >= 100
            |||,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyFrontendRequestErrors',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendRequestErrors' % $._config,
              summary: 'HAProxy: Request error rate increase detected on {{ $labels.frontend }} frontend',
            },
            expr: 'sum by (frontend) (rate(haproxy_frontend_request_errors_total{frontend!~"stats|healthz|error503noendpoints|.*default-backend"}[2m])) / sum by (frontend) (rate(haproxy_frontend_http_requests_total[2m])) * 100 > 1',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyFrontendRequestErrors',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendRequestErrors' % $._config,
              summary: 'HAProxy: Request error rate increase detected on {{ $labels.frontend }} frontend',
            },
            expr: 'sum by (frontend) (rate(haproxy_frontend_request_errors_total{frontend!~"stats|healthz|error503noendpoints|.*default-backend"}[2m])) / sum by (frontend) (rate(haproxy_frontend_http_requests_total[2m])) * 100 > 5',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyBackendRequestQueued',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendRequestQueued' % $._config,
              summary: 'HAProxy: Request are queuing up on the {{ $labels.mintel_com_service }} backend',
            },
            expr: 'sum by (mintel_com_service, label_app_mintel_com_owner) (haproxy:haproxy_backend_current_queue:labeled) > 10',
            'for': '2m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyBackendRequestQueued',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendRequestQueued' % $._config,
              summary: 'HAProxy: Request are queuing up on the {{ $labels.mintel_com_service }} backend',
            },
            expr: 'sum by (mintel_com_service, label_app_mintel_com_owner) (haproxy:haproxy_backend_current_queue:labeled) > 100',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyBackendRequestQueuedTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendRequestQueuedTime' % $._config,
              summary: 'HAProxy: Excessive request queue time on the {{ $labels.mintel_com_service }} backend',
            },
            expr: 'haproxy:http_backend_queue_time_seconds_bucket:histogram_quantile > 0.3',
            'for': '2m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyBackendRequestQueuedTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendRequestQueuedTime' % $._config,
              summary: 'HAProxy: Excessive request queue time on the {{ $labels.mintel_com_service }} backend',
            },
            expr: 'haproxy:http_backend_queue_time_seconds_bucket:histogram_quantile > 0.5',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyBackendResponseErrors',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendResponseErrors' % $._config,
              summary: 'HAProxy: Response errors detected on {{ $labels.mintel_com_service }} backend',
            },
            expr: 'sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_response_errors_total:labeled[1m])) > 1',
            'for': '2m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyBackendResponseErrors',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendResponseErrors' % $._config,
              summary: 'HAProxy: Response errors detected on {{ $labels.mintel_com_service }} backend',
            },
            expr: 'sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_response_errors_total:labeled[1m])) > 10',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyBackendResponseErrors5xx',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendResponseErrors5xx' % $._config,
              summary: 'HAProxy: Increased number of 5xx responses on {{ $labels.mintel_com_service }} service',
            },
            expr: |||
              (
              sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled{code=~"5.."}[1m]))
              /
              sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled[1m]))
              ) * 100 > 1
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyBackendResponseErrors5xx',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendResponseErrors5xx' % $._config,
              summary: 'HAProxy: Increased number of 5xx responses on {{ $labels.mintel_com_service }} service',
            },
            expr: |||
              (
              sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled{code=~"5.."}[1m]))
              /
              sum by (mintel_com_service, label_app_mintel_com_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled[1m]))
              ) * 100 > 10
            |||,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyBackendDown',
            annotations: {
              description: 'HAProxy: {{ $labels.mintel_com_service }} backend has been down for at least 1m on all Ingress pods',
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyBackendDown' % $._config,
            },
            expr: 'sum by (mintel_com_service, label_app_mintel_com_owner) (haproxy:haproxy_backend_up:labeled) == 0',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyServerInBackendUpPercentageLow',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyServerInBackendUpPercentageLow' % $._config,
              summary: 'HAProxy: The percentage of server up in backend for {{ $labels.mintel_com_service }} service is low on ingress {{ $labels.pod }} : {{ $value }}%',
            },
            expr: |||
              (
              sum by (mintel_com_service, label_app_mintel_com_owner, pod) (haproxy:haproxy_server_up:labeled)
              /
              count by (mintel_com_service, label_app_mintel_com_owner, pod) (haproxy:haproxy_server_up:labeled)
              ) * 100 < 75 
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'HAProxyServerInBackendUpPercentageLow',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyServerInBackendUpPercentageLow' % $._config,
              summary: 'HAProxy: The percentage of server up in backend for {{ $labels.mintel_com_service }} service is low on ingress {{ $labels.pod }} : {{ $value }}%',
            },
            expr: |||
              (
              sum by (mintel_com_service, label_app_mintel_com_owner, pod) (haproxy:haproxy_server_up:labeled)
              /
              count by (mintel_com_service, label_app_mintel_com_owner, pod) (haproxy:haproxy_server_up:labeled)
              ) * 100 < 50
            |||,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'HAProxyFrontendIncreasedRequests',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#HAProxyFrontendIncreasedRequests' % $._config,
              summary: 'HAProxy: The number of requests on frontend {{ $labels.frontend }} has increades by {{ $value }} in the last %(haProxyFrontendIncreaseRequestsRateInterval)s minutes compared to the %(haProxyFrontendIncreaseRequestsQuantileValue)s quantile over the last %(haProxyFrontendIncreaseRequestsQuantileRange)s' % $._config,
            },
            expr: |||
              100 * 
              avg by (frontend) ( 
                rate(haproxy_frontend_http_requests_total{frontend!~"stats|healthz|.*default-backend"}[%(haProxyFrontendIncreaseRequestsRateInterval)s]) /
                quantile_over_time(%(haProxyFrontendIncreaseRequestsQuantileValue)s, rate(haproxy_frontend_http_requests_total{frontend!~"stats|healthz|.*default-backend"}[%(haProxyFrontendIncreaseRequestsRateInterval)s])[%(haProxyFrontendIncreaseRequestsQuantileRange)s:%(haProxyFrontendIncreaseRequestsRateInterval)s])
              ) > %(haProxyFrontendIncreaseRequestsPercentageThreshold)s
            ||| % $._config,
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
