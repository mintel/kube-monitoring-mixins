{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'external-dns.alerts',
        rules: [
          {
            alert: 'ExternalDnsLastSyncOld',
            annotations: {
              description: 'External DNS Last Sync is very Old',
              summary: 'External DNS Last Sync is very Old',
              runbook_url: '%(runBookBaseURL)s/core/ExternalDNS.md#ExternalDnsLastSyncOld' % $._config,
            },
            expr: '(time() - external_dns_controller_last_sync_timestamp_seconds{job="external-dns"} > 90) or external_dns_controller_last_sync_timestamp_seconds{job="external-dns"} == 0',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ExternalDnsRegistryErrorsIncrease',
            annotations: {
              description: 'External DNS registry Errors increasing constantly',
              summary: 'External DNS registry Errors increasing constantly',
              runbook_url: '%(runBookBaseURL)s/core/ExternalDNS.md#ExternalDnsRegistryErrorsIncrease' % $._config,
            },
            expr: 'increase(external_dns_registry_errors_total{job="external-dns"}[5m]) > 0',
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
