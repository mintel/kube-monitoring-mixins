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
            expr: 'time() - external_dns_controller_last_sync_timestamp_seconds{job="external-dns"} > 60',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
