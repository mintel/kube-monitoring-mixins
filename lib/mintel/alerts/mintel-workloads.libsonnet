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
          {
            alert: 'KubePDBDisruptionsAllowedZero',
            annotations: {
              description: 'PDB Allowed Disruptions {{ $labels.namespace}}/{{ $labels.poddisruptionbudget }} has been at 0 for too long',
              runbook_url: '%(runBookBaseURL)s/core/KubePDBDisruptionsAllowedZero.md' % $._config,
              summary: 'PDB Allowed Disruptions is 0',
            },
            expr: 'kube_poddisruptionbudget_status_pod_disruptions_allowed == 0',
            'for': '60m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
