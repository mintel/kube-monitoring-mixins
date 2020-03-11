{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'filebeat.alerts',
        rules: [
          {
            alert: 'FilebeatHighOutputFailures',
            annotations: {
              description: 'Filebeat output failures have been increasing for 1h',
              summary: 'The number of Filebeat events failing to push to ElasticSearch has been increasing for 1h',
              runbook_url: '%(runBookBaseURL)s/core/FilebeatHighOutputFailures.md' % $._config,
            },
            expr: 'sum by (service,pod,type) (increase(filebeat_libbeat_output_events{type="failed"}[5m])) > 0',
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FilebeatHighOutputDropped',
            annotations: {
              description: 'Filebeat output dropped events have been increasing for 1h',
              summary: 'The number of Filebeat events being dropped at the output stage haas been increasing for 1h',
              runbook_url: '%(runBookBaseURL)s/core/FilebeatHighOutputDropped.md' % $._config,
            },
            expr: 'sum by (service,pod,type) (increase(filebeat_libbeat_output_events{type="dropped"}[5m])) > 0',
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FilebeatHighPipelineFailures',
            annotations: {
              description: 'Filebeat pipeline failures have been increasing for 1h',
              summary: 'The number of Filebeat events failing to be processed has been increasing for 1h',
              runbook_url: '%(runBookBaseURL)s/core/FilebeatHighPipelineFailures.md' % $._config,
            },
            expr: 'sum by (service,pod,type) (increase(filebeat_libbeat_pipeline_events{type="failed"}[5m])) > 0',
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FilebeatRegistryWriteFailing',
            annotations: {
              description: 'Filebeat registry write failures increasing for 1h',
              summary: 'The number of times Filebeat has failed to write to its registry has been increasing for 1h',
              runbook_url: '%(runBookBaseURL)s/core/FilebeatRegistryWriteFailing.md' % $._config,
            },
            expr: 'sum by (service,pod,type) (increase(filebeat_registrar_writes[5m])) > 0',
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
