{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-disks.alerts',
        rules: [
          {
            alert: 'KubePersistentVolumeInodeUsageCritical',
            expr: |||
              mintel:pvc:inodes_free:percentage <= 3
            |||,
            'for': '1h',
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
              mintel:pvc:inodes_free:percentage < 15 and
              predict_linear(mintel:pvc:inodes_free:percentage[4h], 4 * 24 * 3600) <= 0
            |||,
            'for': '1h',
            labels: {
              severity: 'warning',
            },
            annotations: {
              description: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace\n                {{ $labels.exported_namespace }} is predicted to use all its inodes within the\n                next 4 days',
              runbook_url: '%(runBookBaseURL)s/core/KubePersistentVolumeInodePredictedUsageCritical.md' % $._config,
              summary: 'Persistent Volume inodes predicted to fill up',
            },
          },
          {
            alert: 'KubePersistentVolumeInodePredictedUsageCritical',
            expr: |||
              mintel:pvc:inodes_free:percentage < 15 and
              predict_linear(mintel:pvc:inodes_free:percentage[4h], 4 * 60 * 60) <= 0
            |||,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              description: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace\n                {{ $labels.exported_namespace }} is predicted to use all its inodes within the\n                next 4 hours',
              runbook_url: '%(runBookBaseURL)s/core/KubePersistentVolumeInodePredictedUsageCritical.md' % $._config,
              summary: 'Persistent Volume inodes predicted to fill up',
            },
          },
          {
            alert: 'KubePersistentVolumeFullInFourHours',
            expr: |||
              100 * (
                kubelet_volume_stats_available_bytes{%(prefixedNamespaceSelector)s%(kubeletSelector)s}
                  /
                kubelet_volume_stats_capacity_bytes{%(prefixedNamespaceSelector)s%(kubeletSelector)s}
              ) < 20
              and
              predict_linear(kubelet_volume_stats_available_bytes{%(prefixedNamespaceSelector)s%(kubeletSelector)s}[%(volumeFullPredictionSampleTime)s], 4 * 60 * 60) < 0
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four hours. Currently {{ printf "%0.2f" $value }}% is available.',
            },
          },
        ],
      },
    ],
  },
}
