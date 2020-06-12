{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'flux.alerts',
        rules: [
          {
            alert: 'FluxDaemonGeneralSyncError',
            annotations: {
              description: 'General flux sync errors',
              summary: 'General Flux Daemon sync error',
              runbook_url: '%(runBookBaseURL)s/core/flux.md#fluxdaemongeneralsyncerror' % $._config,
            },
            expr: 'delta(flux_daemon_sync_duration_seconds_count{%(fluxJobSelector)s,success="true"}[%(fluxDeltaIntervalMinutes)sm]) < 1 or absent(flux_daemon_sync_duration_seconds_count{%(fluxJobSelector)s,success="true"})' % $._config,
            'for': '120m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FluxManifestsSyncError',
            annotations: {
              description: 'Flux manifests sync errors',
              summary: 'Flux Manifests sync error',
              runbook_url: '%(runBookBaseURL)s/core/flux.md#fluxmanifestssyncerror' % $._config,
            },
            expr: 'flux_daemon_sync_manifests{%(fluxJobSelector)s,success="false"} > 0' % $._config,
            'for': '60m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FluxMemCacheErrors',
            annotations: {
              description: 'Flux Errors talking to memcached',
              summary: 'Flux Errors talking to memcached',
              runbook_url: '%(runBookBaseURL)s/core/flux.md#fluxmemcacheerrors' % $._config,
            },
            expr: 'delta(flux_cache_request_duration_seconds_count{%(fluxJobSelector)s,success="false"}[%(fluxDeltaDoubleIntervalMinutes)sm]) > 0' % $._config,
            'for': '60m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FluxRemoteFetchErrors',
            annotations: {
              description: 'Flux errors fetching from remote registry',
              summary: 'Flux errors fetching from remote registry',
              runbook_url: '%(runBookBaseURL)s/core/flux.md#fluxremotefetcherrors' % $._config,
            },
            expr: 'delta(flux_client_fetch_duration_seconds_count{%(fluxJobSelector)s,success="false"}[%(fluxDeltaDoubleIntervalMinutes)sm]) > 0' % $._config,
            'for': '240m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'FluxReleaseErrors',
            annotations: {
              description: 'Flux image release errors',
              summary: 'Flux release errors',
              runbook_url: '%(runBookBaseURL)s/core/flux.md#fluxreleaseerrors' % $._config,
            },
            expr: 'delta(flux_fluxsvc_release_duration_seconds_count{%(fluxJobSelector)s,success="false"}[%(fluxDeltaIntervalMinutes)sm]) > 0' % $._config,
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
