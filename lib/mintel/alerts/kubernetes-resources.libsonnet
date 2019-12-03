{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'kubernetes-resources-mintel.alerts',
        rules: [
          {
            alert: 'KubeCPUOvercommit',
            annotations: {
              message: 'Cluster has overcommitted CPU resource requests for Namespaces.',
              runbook_url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuovercommit',
            },
            expr: |||
              sum(kube_resourcequota{%(prefixedNamespaceSelector)s%(kubeStateMetricsSelector)s, type="hard", resource="requests.cpu"})
                /
              sum(node:node_num_cpu:sum)
                > %(namespaceOvercommitFactor)s
            ||| % $._config,
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
            expr: |||
              sum(kube_resourcequota{%(prefixedNamespaceSelector)s%(kubeStateMetricsSelector)s, type="hard", resource="requests.memory"})
                /
              sum(node_memory_MemTotal_bytes{%(nodeExporterSelector)s})
                > %(namespaceOvercommitFactor)s
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
