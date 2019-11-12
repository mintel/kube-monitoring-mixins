{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'kubernetes-resources.alerts',
        rules: [
          {
            alert: 'KubeCPUOvercommit',
            annotations: {
              message: 'Cluster has overcommitted CPU resource requests for Pods and cannot tolerate node failure.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuovercommit',
            },
            expr: 'sum(namespace_name:kube_pod_container_resource_requests_cpu_cores:sum)\n  /\nsum(node:node_num_cpu:sum)\n  >\n(count(node:node_num_cpu:sum)-1) / count(node:node_num_cpu:sum)\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubeMemOvercommit',
            annotations: {
              message: 'Cluster has overcommitted memory resource requests for Pods and cannot tolerate node failure.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememovercommit',
            },
            expr: 'sum(namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)\n  /\nsum(node_memory_MemTotal_bytes)\n  >\n(count(node:node_num_cpu:sum)-1)\n  /\ncount(node:node_num_cpu:sum)\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubeCPUOvercommit',
            annotations: {
              message: 'Cluster has overcommitted CPU resource requests for Namespaces.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuovercommit',
            },
            expr: 'sum(kube_resourcequota{job="kube-state-metrics", type="hard", resource="requests.cpu"})\n  /\nsum(node:node_num_cpu:sum)\n  > 1.5\n',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubeMemOvercommit',
            annotations: {
              message: 'Cluster has overcommitted memory resource requests for Namespaces.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememovercommit',
            },
            expr: 'sum(kube_resourcequota{job="kube-state-metrics", type="hard", resource="requests.memory"})\n  /\nsum(node_memory_MemTotal_bytes{job="node-exporter"})\n  > 1.5\n',
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
