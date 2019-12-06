{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'git-sync.alerts',
        rules: [
          {
            alert: 'GitSyncFailing',
            annotations: {
              description: 'Git-sync sidecar in the pod {{ $labels.pod }} has failed 45 times during the last hour.',
              summary: 'Git-sync failing to pull git repos',
              runbook_url: '%(runBookBaseURL)s/core/GitSyncFailing.md' % $._config,
            },
            expr: 'increase(git_sync_count_total{status="error"}[60m]) > 45',
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
