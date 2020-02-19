{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-pod.rules',
        rules: [
          {
            expr: 'label_replace( (sum by (namespace, container, pod, environment) ( sum(container_memory_usage_bytes{container!=""}) by (container, pod) * on (pod) group_left(environment, namespace) label_replace(kube_pod_labels{label_app!=""},"pod","$1","pod","(.*)") ) / sum( label_replace( label_replace( kube_pod_container_resource_limits_memory_bytes{container!=""}, "container", "$1", "container",  "(.*)" ), "pod", "$1", "pod", "(.*)" ) ) by (namespace, container, pod, environment) * 100), "service", "$1", "container", "(.*)")',
            record: 'mintel:pod:usage_vs_limits_memory:percent',
          }
          {
            expr: 'label_replace( (sum by (namespace, container, pod, environment) ( sum(container_memory_usage_bytes{container!=""}) by (container, pod) * on (pod) group_left(environment, namespace) label_replace(kube_pod_labels{label_app!=""},"pod","$1","pod","(.*)") ) / sum( label_replace( label_replace( kube_pod_container_resource_requests_memory_bytes{container!=""}, "container", "$1", "container",  "(.*)" ), "pod", "$1", "pod", "(.*)" ) ) by (namespace, container, pod, environment) * 100), "service", "$1", "container", "(.*)")',
            record: 'mintel:pod:usage_vs_request_memory:percent',
          },
          {
            expr: 'count by(created_by_kind, created_by_name, node) (kube_pod_info{created_by_kind!~"<none>|Job"})',
            record: 'mintel:pod:allocation:node',
          },
          {
            expr: 'count by(created_by_kind, created_by_name, label_failure_domain_beta_kubernetes_io_zone) (kube_pod_info{created_by_kind!~"<none>|Job"} * on(node) group_left(label_failure_domain_beta_kubernetes_io_zone) kube_node_labels)',
            record: 'mintel:pod:allocation:zone',
          },
          {
            expr: 'count by(created_by_kind, created_by_name) (kube_pod_info{created_by_kind!~"<none>|Job"})',
            record: 'mintel:pod:allocation:totals',
          },
        ],
      },
    ],
  },
}
