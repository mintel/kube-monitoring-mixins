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
    ],
  },
}
