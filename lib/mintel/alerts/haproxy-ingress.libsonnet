{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'haproxy-ingress',
        rules: [{
          alert: 'HAProxyFrontendSessionUsage',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyFrontendSessionUsage',
            summary: 'HAProxy: Session usage on {{ $labels.frontend }} frontend has reached {{ $value }}%',
          },
          expr: 'sum by (frontend) (haproxy_frontend_current_sessions) / sum by (frontend) (haproxy_frontend_limit_sessions) * 100 >= 80',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyFrontendSessionUsage',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyFrontendSessionUsage',
            summary: 'HAProxy: Session usage on {{ $labels.frontend }} frontend has reached {{ $value }}%',
          },
          expr: 'sum by (frontend) (haproxy_frontend_current_sessions) / sum by (frontend) (haproxy_frontend_limit_sessions) * 100 >= 90',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyFrontendRequestErrors',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyFrontendRequestErrors',
            summary: 'HAProxy: Request error rate increase detected on {{ $labels.frontend }} frontend',
          },
          expr: 'sum by (frontend) (rate(haproxy_frontend_request_errors_total[1m])) / sum by (frontend) (rate(haproxy_frontend_http_requests_total[1m])) * 100 > 1',
          'for': '3m',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyFrontendRequestErrors',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyFrontendRequestErrors',
            summary: 'HAProxy: Request error rate increase detected on {{ $labels.frontend }} frontend',
          },
          expr: 'sum by (frontend) (rate(haproxy_frontend_request_errors_total[1m])) / sum by (frontend) (rate(haproxy_frontend_http_requests_total[1m])) * 100 > 5',
          'for': '3m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyBackendRequestQueued',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendRequestQueued',
            summary: 'HAProxy: Request are queuing up on the {{ $labels.mintel_com_service }} backend',
          },
          expr: 'sum by (mintel_com_service, label_app_kubernetes_io_owner) (haproxy:haproxy_backend_current_queue:labeled) > 10',
          'for': '2m',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyBackendRequestQueued',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendRequestQueued',
            summary: 'HAProxy: Request are queuing up on the {{ $labels.mintel_com_service }} backend',
          },
          expr: 'sum by (mintel_com_service, label_app_kubernetes_io_owner) (haproxy:haproxy_backend_current_queue:labeled) > 100',
          'for': '2m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyBackendRequestQueuedTime',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendRequestQueuedTime',
            summary: 'HAProxy: Excessive request queue time on the {{ $labels.mintel_com_service }} backend',
          },
          expr: 'haproxy:http_backend_queue_time_seconds_bucket:histogram_quantile > 0.1',
          'for': '2m',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyBackendRequestQueuedTime',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendRequestQueuedTime',
            summary: 'HAProxy: Excessive request queue time on the {{ $labels.mintel_com_service }} backend',
          },
          expr: 'haproxy:http_backend_queue_time_seconds_bucket:histogram_quantile > 0.5',
          'for': '2m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyBackendResponseErrors',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendResponseErrors',
            summary: 'HAProxy: Response errors detected on {{ $labels.mintel_com_service }} backend',
          },
          expr: 'sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_response_errors_total:labeled[1m])) > 1',
          'for': '2m',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyBackendResponseErrors',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendResponseErrors',
            summary: 'HAProxy: Response errors detected on {{ $labels.mintel_com_service }} backend',
          },
          expr: 'sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_response_errors_total:labeled[1m])) > 10',
          'for': '2m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyBackendResponseErrors5xx',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendResponseErrors5xx',
            summary: 'HAProxy: Increased number of 5xx responses on {{ $labels.mintel_com_service }} service',
          },
          expr: '(\n  sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled{code=~"5.."}[1m]))\n  /\n  sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled[1m]))\n) * 100 > 1',
          'for': '5m',
          labels: {
            severity: 'warning',
          },
        }
                {
          alert: 'HAProxyBackendResponseErrors5xx',
          annotations: {
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendResponseErrors5xx',
            summary: 'HAProxy: Increased number of 5xx responses on {{ $labels.mintel_com_service }} service',
          },
          expr: '(\n  sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled{code=~"5.."}[1m]))\n  /\n  sum by (mintel_com_service, label_app_kubernetes_io_owner) (rate(haproxy:haproxy_backend_http_responses_total:labeled[1m]))\n) * 100 > 10',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
        }
                {
          alert: 'HAProxyBackendDown',
          annotations: {
            description: 'HAProxy: {{ $labels.mintel_com_service }} service has been down for at least 1m',
            runbook_url: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks/core/HAProxy.md#HAProxyBackendDown',
          },
          expr: 'sum by (mintel_com_service, label_app_kubernetes_io_owner) (haproxy:haproxy_backend_up:labeled) == 0',
          'for': '1m',
          labels: {
            severity: 'critical',
          },
        }],
      },
    ],
  },
}
