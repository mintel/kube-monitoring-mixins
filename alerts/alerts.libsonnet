{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-containers',
        rules: [
          {
            alert: 'ContainerCombinedIoHighOverTime',
            expr: |||
              rate(container_fs_reads_bytes_total{%(cadvisorSelector)s,%(containerIoDiskDeviceSelector)s}[%(containerIoDiskDeviceRateInterval)s])
              +
              rate(container_fs_writes_bytes_total{%(cadvisorSelector)s,%(containerIoDiskDeviceSelector)s}[%(containerIoDiskDeviceRateInterval)s])
              > %(containerIoBytesValueThreshold)s
            ||| % $._config,
            'for': $._config.containerIoBytesTimeThreshold,
            labels: {
              severity: $._config.containerIoCriticality,
            },
            annotations: {
              runbook_url: 'https://gitlab.com/mintel/satoshi/monitoring/runbooks/blob/master/satoshi/platform/ContainerCombinedIoHighOverTime.md',
              summary: 'Container have been doing an unusual amount of IO',
              description: 'Container {{ $labels.container_name }} in Pod {{ $labels.pod_name }} have been doing an unusual amount of Sustained IO on {{ $labels.device }} for the specified time',
            },
          },
        ],
      },
      {
        name: 'mintel-disks',
        rules: [
          {
            alert: 'KubePersistentVolumeInodeUsageCritical',
            expr: |||
              mintel:pvc:inodes_free:percentage <= 5
            |||,
            "for": '5m',
            labels: {
              severity: warning
              context: 'cluster',
            },
            annotations: {
              summary: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace {{ $labels.exported_namespace }} has {{ $value }}% inodes left',
              description: 'The free space for device {{ $labels.device }} on node {{ $labels.instance }} is Predicted to be less than 5% in the next 3 hours at the current rate based on the last 4h samples',
              runbook_url: 'https://gitlab.com/mintel/satoshi/monitoring/runbooks/blob/master/satoshi/platform/KubePersistentVolumeInodeUsageCritical.md',
            },
          },
          {
            alert: 'KubePersistentVolumeInodePredictedUsageCritical',
            expr: |||
              predict_linear(mintel:pvc:inodes_free:percentage[4h], 4 * 24 * 3600) <= 0
            |||,
            "for": '10m',
            labels: {
              severity: critical
              context: 'cluster',
            },
            annotations: {
              description: 'The persistent volume {{ $labels.persistentvolumeclaim }} in namespsace
                {{ $labels.exported_namespace }} is predicted to use all its inodes within the
                next 4 days',
                runbook_url: 'https://gitlab.com/mintel/satoshi/monitoring/runbooks/blob/master/satoshi/platform/KubePersistentVolumeInodePredictedUsageCritical.md',
                summary: 'Persistent Volume inodes predicted to fill up'
            },
          },
        ],
      },
    ],
  },
}
