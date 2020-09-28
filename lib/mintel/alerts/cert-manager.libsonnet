{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'cert-manager.alerts',
        rules: [
          {
            alert: 'CertManagerCertificateExpireSoon',
            annotations: {
              description: 'Cert Manager managed certificate for {{ $labels.namespace }}/{{ $labels.name }} will expire in less then 29 days',
              summary: 'Certificate managed by Cert-Manager will expire soon in less then 29 days',
              runbook_url: '%(runBookBaseURL)s/core/CertManager.md#CertManagerCertificateExpireSoon' % $._config,
            },
            expr: 'certmanager_certificate_expiration_timestamp_seconds{%(certManagerSelector)s} - time() < 2506000' % $._config,
            'for': '60m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'CertManagerCertificateExpireSoon',
            annotations: {
              description: 'Cert Manager managed certificate for {{ $labels.namespace }}/{{ $labels.name }} will expire in less then 14 days',
              summary: 'Certificate managed by Cert-Manager will expire soon in less then 14 days',
              runbook_url: '%(runBookBaseURL)s/core/CertManager.md#CertManagerCertificateExpireSoon' % $._config,
            },
            expr: 'certmanager_certificate_expiration_timestamp_seconds{%(certManagerSelector)s} - time() < 1210000' % $._config,
            'for': '60m',
            labels: {
              page: 'false',
              severity: 'critical',
            },
          },
          {
            alert: 'CertManagerCertificateNotReady',
            annotations: {
              description: 'Cert Manager certificate for {{ $labels.namespace }}/{{ $labels.name }} has not reached Ready status in 60 minutes',
              summary: 'Certificate managed by Cert-Manager has not reached Ready Status in 60 minutes',
              runbook_url: '%(runBookBaseURL)s/core/CertManager.md#CertManagerCertificateNotReady' % $._config,
            },
            expr: 'certmanager_certificate_ready_status{%(certManagerSelector)s,condition="True"} == 0' % $._config,
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
