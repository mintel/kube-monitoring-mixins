{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'blackbox.alerts',
        rules: [
          {
            alert: 'SiteIsDown',
            annotations: {
              description: 'Site {{$labels.target}} has been down (non 2xx code) for 1 minute according to {{ $value }}% of Blackbox probes',
              summary: 'Site {{$labels.target}} is down (non 2xx code)',
              runbook_url: '%(runBookBaseURL)s/core/SiteIsDown.md' % $._config,
            },
            expr: '100 * count by (target,job,app_mintel_com_owner) (probe_success{job="blackbox"} < 1) / blackbox_node_count >= 50',
            'for': '1m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'SiteIsDown',
            annotations: {
              description: 'Site {{$labels.target}} has been down (non 2xx code) for more than 3 minutes according to {{ $value }}% of Blackbox probes',
              summary: 'Site {{$labels.target}} is down (non 2xx code)',
              runbook_url: '%(runBookBaseURL)s/core/SiteIsDown.md' % $._config,
            },
            expr: '100 * count by (target,job,app_mintel_com_owner) (probe_success{job="blackbox"} < 1) / blackbox_node_count >= 50',
            'for': '3m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'SiteStatusIsFlapping',
            annotations: {
              description: 'Site {{$labels.target}} status (non 2xx code) has changed more than 5 times over the last 10 minutes according to {{ $value }}% of Blackbox probes',
              summary: 'Site {{$labels.target}} status (non 2xx code) is flapping',
              runbook_url: '%(runBookBaseURL)s/core/SiteStatusIsFlapping.md' % $._config,
            },
            expr: '100 * count by (target,job,app_mintel_com_owner) (changes(probe_success{job="blackbox"}[10m]) > 5) / blackbox_node_count >= 50',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'TargetIsDown',
            annotations: {
              description: 'Target {{$labels.target}} has been down for 5 minutes according to {{ $value }}% of Blackbox probes',
              summary: 'Target {{$labels.target}} is down',
              runbook_url: '%(runBookBaseURL)s/core/TargetIsDown.md' % $._config,

            },
            expr: '100 * count by (target,job,app_mintel_com_owner) (up{job="blackbox"} == 0) / blackbox_node_count >= 50',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'TargetSSLCertExpireNear',
            annotations: {
              description: 'Target {{$labels.target}} SSL Certificate is due to expire in less than 29 days',
              summary: 'Target {{$labels.target}} SSL Certificate is due to expire in less than 29 days',
              runbook_url: '%(runBookBaseURL)s/core/TargetSSLCertExpireNear.md' % $._config,
            },
            expr: '(min by(target,job,app_mintel_com_owner) (probe_ssl_earliest_cert_expiry{} - time()) ) / 60 / 60 / 24 < 29',
            'for': '24h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'TargetSSLCertExpireNear',
            annotations: {
              description: 'Target {{$labels.target}} SSL Certificate is due to expire in less than 14 days',
              summary: 'Target {{$labels.target}} SSL Certificate is due to expire in less than 14 days',
              runbook_url: '%(runBookBaseURL)s/core/TargetSSLCertExpireNear.md' % $._config,

            },
            expr: '(min by(target,job,app_mintel_com_owner) (probe_ssl_earliest_cert_expiry{} - time()) ) / 60 / 60 / 24 < 14',
            'for': '1h',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
