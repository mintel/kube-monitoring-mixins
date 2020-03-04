{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-workload.alerts',
        rules: [
          {
            alert: 'KubeDeploymentStatusUnavailable',
            annotations: {
              description: 'Deployment {{ $labels.namespace}} / {{ $labels.deployment }} has unavailable pods',
              runbook_url: '%(runBookBaseURL)s/core/KubeDeploymentStatusUnavailable.md' % $._config,
              summary: 'Deployment pods unavailable',
            },
            expr: 'kube_deployment_status_replicas_unavailable > 0',
            'for': '30m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'KubeDaemonSetStatusUnavailable',
            annotations: {
              description: 'DaemonSet {{ $labels.namespace}} / {{ $labels.daemonset }} has unavailable pods',
              runbook_url: '%(runBookBaseURL)s/core/KubeDaemonSetStatusUnavailable.md' % $._config,
              summary: 'Daemonset pods unavailable',
            },
            expr: 'kube_daemonset_status_number_unavailable > 0',
            'for': '30m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
