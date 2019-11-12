{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-disks.alerts',
        rules: [
          {
            alert: 'KubePersistentVolumeInodeUsageCritical',
            expr: |||
              mintel:pvc:inodes_free:percentage <= 5
            |||,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace {{ $labels.exported_namespace }} has {{ $value }}% inodes left',
              description: 'The free space for device {{ $labels.device }} on node {{ $labels.instance }} is Predicted to be less than 5% in the next 3 hours at the current rate based on the last 4h samples',
              runbook_url: '%(runBookBaseURL)s/core/KubePersistentVolumeInodeUsageCritical.md' % $._config,

            },
          },
          {
            alert: 'KubePersistentVolumeInodePredictedUsageCritical',
            expr: |||
              predict_linear(mintel:pvc:inodes_free:percentage[4h], 4 * 24 * 3600) <= 0
            |||,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              description: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace\n                {{ $labels.exported_namespace }} is predicted to use all its inodes within the\n                next 4 days',
              runbook_url: '%(runBookBaseURL)s/core/KubePersistentVolumeInodePredictedUsageCritical.md' % $._config,
              summary: 'Persistent Volume inodes predicted to fill up',
            },
          },
        ],
      },
    ],
  },
}
