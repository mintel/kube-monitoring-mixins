{
  prometheusRules+:: {
    groups+: [
      {
        name: 'haproxy-ingress.rules',
        rules: [
          {
            expr: |||
              label_replace(
              label_replace(http_backend_response_wait_seconds_bucket{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
              * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:http_backend_response_wait_seconds_bucket:labeled',
          },
          {
            expr: |||
              label_replace(
              label_replace(http_backend_queue_time_seconds_bucket{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:http_backend_queue_time_seconds_bucket:labeled',
          },
          {
            expr: |||
              label_replace(
              label_replace(haproxy_backend_current_queue{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:haproxy_backend_current_queue:labeled',
          },
          {
            expr: |||
              label_replace(
              label_replace(haproxy_backend_response_errors_total{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:haproxy_backend_response_errors_total:labeled',
          },
          {
            expr: |||
              label_replace(
              label_replace(haproxy_backend_http_responses_total{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:haproxy_backend_http_responses_total:labeled',
          },
          {
            expr: |||
              label_replace(
              label_replace(haproxy_backend_up{backend!~"(error|stats|httpback|upstream).*"}, "mintel_com_service", "$1", "backend", "(.*)-\\d+$")
                * on(mintel_com_service) group_left(label_app_kubernetes_io_owner)
                label_join(kube_service_labels, "mintel_com_service", "-", "namespace", "service"),
              "label_app_kubernetes_io_owner",
              "satoshi",
              "label_app_kubernetes_io_owner",
              ""
              )
            |||,
            record: 'haproxy:haproxy_backend_up:labeled',
          },
          {
            expr: |||
              histogram_quantile(0.95, sum(rate(haproxy:http_backend_response_wait_seconds_bucket:labeled[5m])) by (mintel_com_service, le, label_app_kubernetes_io_owner))
            |||,
            labels: {
              quantile: '0.95',
            },
            record: 'haproxy:http_backend_response_wait_seconds_bucket:histogram_quantile',
          },
          {
            expr: |||
              histogram_quantile(0.95, sum(rate(haproxy:http_backend_queue_time_seconds_bucket:labeled[5m])) by (mintel_com_service, le, label_app_kubernetes_io_owner))
            |||,
            labels: {
              quantile: '0.95',
            },
            record: 'haproxy:http_backend_queue_time_seconds_bucket:histogram_quantile',
          },
        ],
      },
    ],
  },
}
