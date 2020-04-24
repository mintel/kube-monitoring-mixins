{
  prometheusRules+:: {
    groups+: [
      {
        name: 'haproxy-ingress.rules',
        rules: [
          {
            expr: |||
              label_replace(haproxy_backend_response_errors_total{backend!~"(error|stats|.*default-backend)"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_mintel_com_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service")
              )
            |||,
            record: 'haproxy:haproxy_backend_response_errors_total:counter',
          },
          {
            expr: |||
              sum by (mintel_com_service, label_app_mintel_com_owner, job, pod) (rate(haproxy:haproxy_backend_response_errors_total:counter[1m]))
            |||,
            record: 'haproxy:haproxy_backend_response_errors_total:rate:1m',
          },
          {
            expr: |||
              label_replace(haproxy_backend_http_responses_total{backend!~"(error|stats|.*default-backend)"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_mintel_com_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service")
            |||,
            record: 'haproxy:haproxy_backend_http_responses_total:counter',
          },
          {
            expr: |||
              sum by (mintel_com_service, label_app_mintel_com_owner, job, pod) (rate(haproxy:haproxy_backend_http_responses_total:counter{code=~"5.."}[1m]))
              /
              sum by (mintel_com_service, label_app_mintel_com_owner, job, pod) (rate(haproxy:haproxy_backend_http_responses_total:counter[1m]))
              ) * 100
            |||,
            record: 'haproxy:haproxy_backend_http_responses_total:percentage:1m',
          },
          {
            expr: |||
              label_replace(haproxy_backend_up{backend!~"(error|stats|.*default-backend)"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_mintel_com_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service")
            |||,
            record: 'haproxy:haproxy_backend_up:counter',
          },
          {
            expr: |||
              label_replace(haproxy_server_up{backend!~"(error|stats|.*default-backend)"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_mintel_com_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service")
            |||,
            record: 'haproxy:haproxy_server_up:counter',
          },
          {
            expr: |||
              (
              sum by (mintel_com_service, label_app_mintel_com_owner, job, pod) (haproxy:haproxy_server_up:counter)
              /
              count by (mintel_com_service, label_app_mintel_com_owner, job, pod) (haproxy:haproxy_server_up:counter)
              ) * 100
            |||,
            record: 'haproxy:haproxy_server_up:percentage',
          },
          {
            expr: |||
              100 * (
                sum by (frontend, job, pod) (haproxy_frontend_current_sessions) 
                / 
                sum by (frontend, job, pod) (haproxy_frontend_limit_sessions)
              )
            |||,
            record: 'haproxy:http_frontend_session_usage:percentage',
          },
        ] + [
          {
            expr: |||
              label_replace(
              histogram_quantile(%(quantile)s,sum (rate(http_backend_request_duration_seconds_bucket{backend!~"(error|stats|.*default-backend)"}[1m])) by (backend,job,le)),
              "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
              * on(mintel_com_service) group_left(label_app_mintel_com_owner)
              label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service")
            ||| % quantile,
            record: std.format('haproxy:http_backend_request_seconds_quantile:%s', std.substr(quantile, 2, 2)),
          }
          for quantile in ['0.50', '0.75', '0.95', '0.99']
        ],
      },
    ],
  },
}
