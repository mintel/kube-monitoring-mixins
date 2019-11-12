{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-pod.rules',
        rules: [{
          expr: 'label_replace( (sum by (namespace, container_name, pod_name, environment) ( sum(container_memory_usage_bytes{container_name!=""}) by (container_name, pod_name) * on (pod_name) group_left(environment, namespace) label_replace(kube_pod_labels{label_app!=""},"pod_name","$1","pod","(.*)") ) / sum( label_replace( label_replace( kube_pod_container_resource_limits_memory_bytes{container!=""}, "container_name", "$1", "container",  "(.*)" ), "pod_name", "$1", "pod", "(.*)" ) ) by (namespace, container_name, pod_name, environment) * 100), "service", "$1", "container_name", "(.*)")',
          record: 'mintel:pod:usage_vs_limits_memory:percent',
        }
                {
          expr: 'label_replace( (sum by (namespace, container_name, pod_name, environment) ( sum(container_memory_usage_bytes{container_name!=""}) by (container_name, pod_name) * on (pod_name) group_left(environment, namespace) label_replace(kube_pod_labels{label_app!=""},"pod_name","$1","pod","(.*)") ) / sum( label_replace( label_replace( kube_pod_container_resource_requests_memory_bytes{container!=""}, "container_name", "$1", "container",  "(.*)" ), "pod_name", "$1", "pod", "(.*)" ) ) by (namespace, container_name, pod_name, environment) * 100), "service", "$1", "container_name", "(.*)")',
          record: 'mintel:pod:usage_vs_request_memory:percent',
        }],
      },
    ],
  },
}
