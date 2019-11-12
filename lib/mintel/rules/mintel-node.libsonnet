{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-node.rules',
        rules: [{
          expr: 'rate(node_network_receive_drop[1m]) + rate(node_network_transmit_drop[1m])',
          record: 'instance:node_network_drop:rate',
        }
                {
          expr: 'rate(node_network_receive_errs[1m]) + rate(node_network_transmit_errs[1m])',
          record: 'instance:node_network_errs:rate',
        }
                {
          expr: '100 - (sum by (node) (kube_pod_container_resource_requests_memory_bytes) / sum by (node) (kube_node_status_allocatable_memory_bytes)) * 100',
          record: 'node:memory_for_pod_available:percentage',
        }
                {
          expr: 'sum by (node) (kube_node_status_allocatable_memory_bytes) - sum by (node) (kube_pod_container_resource_requests_memory_bytes)',
          record: 'node:memory_for_pod_available:bytes',
        }
                {
          expr: '100 - (sum by (node) (kube_pod_container_resource_requests_cpu_cores) / sum by (node) (kube_node_status_allocatable_cpu_cores)) * 100',
          record: 'node:cpu_cores_for_pod_available:percentage',
        }
                {
          expr: 'sum by (node) (kube_node_status_allocatable_cpu_cores) - sum by (node) (kube_pod_container_resource_requests_cpu_cores)',
          record: 'node:cpu_cores_for_pod_available:cores',
        }
                {
          expr: '100 - ( (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) * 100 )',
          record: 'node:conntrack_entries_free:percentage',
        }],
      },
    ],
  },
}
