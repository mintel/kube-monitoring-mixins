local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';
{

  httpRequests(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '1m',
      handlerFilter: 'handler!~"/|/-/healthy|/-/ready"',
    };

    commonPanels.timeseries(
      title='HTTP requests/s',
      description='The number of http endpoints requests',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      linewidth=1,
      format='ops',
      query=|||
        rate(prometheus_http_request_duration_seconds_count{%(selector)s,%(handlerFilter)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='{{handler}}',
    ) + {
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        max: false,
        min: false,
        total: false,
      },

    },

  httpRequestsLatency(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '1m',
      handlerFilter: 'handler!~"/|/-/healthy|/-/ready"',
    };

    commonPanels.timeseries(
      title='HTTP requests Latency',
      description='The latency of http endpoints requests',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      linewidth=1,
      format='s',
      query=|||
        rate(prometheus_http_request_duration_seconds_sum{%(selector)s,%(handlerFilter)s}[%(baseInterval)s])
        /
        rate(prometheus_http_request_duration_seconds_count{%(selector)s,%(handlerFilter)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='{{handler}}',
    ) + {
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        max: false,
        min: false,
        total: false,
      },

    },

  httpRequestsTimeSpent(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '1m',
      handlerFilter: 'handler!~"/|/-/healthy|/-/ready"',
    };

    commonPanels.timeseries(
      title='Time spent in HTTP Requests/s',
      description='The Amount of time spent in http requests each second',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      linewidth=1,
      format='s',
      query=|||
        rate(prometheus_http_request_duration_seconds_sum{%(selector)s,%(handlerFilter)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='{{handler}}',
    ) + {
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        max: false,
        min: false,
        total: false,
      },

    },

  rulesLastDurationTop(selector, topk=10, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      topk: topk,
    };

    commonPanels.timeseries(
      title=std.format('Rule Groups Last Duration top %s', config.topk),
      description='The duration of the last rule group evaluation',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      linewidth=1,
      format='s',
      query=|||
        topk(%(topk)s, prometheus_rule_group_last_duration_seconds{%(selector)s})
      ||| % config,
      legendFormat='{{rule_group}}',
    ),

  rulesEvaluationAverageLatency(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '2m',
    };

    commonPanels.timeseries(
      title='Rule Groups Latency',
      description='The duration of rule group evaluations',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      linewidth=1,
      format='s',
      query=|||
        (
          rate(prometheus_rule_group_duration_seconds_sum{%(selector)s}[$__interval])
          /
          rate(prometheus_rule_group_duration_seconds_count{%(selector)s}[$__interval])
        )
        or
        (
          rate(prometheus_rule_group_duration_seconds_sum{%(selector)s}[%(baseInterval)s])
          /
          rate(prometheus_rule_group_duration_seconds_count{%(selector)s}[%(baseInterval)s])
        )
      ||| % config,
      legendFormat='Average Latency',
    )
    .addTarget(
      promQuery.target(
        |||
          prometheus_rule_group_duration_seconds{quantile="0.99",%(selector)s}
        ||| % config,
        legendFormat='99th Percentile',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          prometheus_rule_group_duration_seconds{quantile="0.9",%(selector)s}
        ||| % config,
        legendFormat='90th Percentile',
      )
    ),

  queriesSliceOps(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '2m',
    };

    commonPanels.timeseries(
      title='Prometheus Queries ops by slice',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      linewidth=1,
      format='short',
      query=|||
        rate(prometheus_engine_query_duration_seconds_count{%(selector)s}[$__interval])
        or
        rate(prometheus_engine_query_duration_seconds_count{%(selector)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='{{ slice }}',
    ),

  queriesSliceLatency(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '2m',
    };

    commonPanels.timeseries(
      title='Prometheus Queries Latency by slice',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      linewidth=1,
      legend_rightSide=false,
      format='s',
      query=|||
        rate(prometheus_engine_query_duration_seconds_sum{%(selector)s}[$__interval])
        or
        rate(prometheus_engine_query_duration_seconds_sum{%(selector)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='{{ slice }}',
    ) + {
      stack: true,
    },


  queriesRunningAverage(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      baseInterval: '5m',
    };

    commonPanels.timeseries(
      title='Prometheus Queries',
      description='Prometheus running queries',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='short',
      query=|||
        avg_over_time(prometheus_engine_queries{%(selector)s}[$__interval])
        or
        avg_over_time(prometheus_engine_queries{%(selector)s}[%(baseInterval)s])
      ||| % config,
      legendFormat='Average Active Queries',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          max_over_time(prometheus_engine_queries{%(selector)s}[$__interval])
          or
          max_over_time(prometheus_engine_queries{%(selector)s}[%(baseInterval)s])
        ||| % config,
        legendFormat='Max Active Queries',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          prometheus_engine_queries_concurrent_max{%(selector)s}
        ||| % config,
        legendFormat='Max Permitted Queries',
      )
    ) + {
      seriesOverrides: [
        {
          alias: 'Max Permitted Queries',
          zindex: -3,
          fill: 0,
          color: '#C4162A',
        },
      ],
    },


  allErrors(selector, interval='5m', span=12)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      interval: interval,
    };

    commonPanels.timeseries(
      title='Failures and Errors',
      description='All Failures and errors',
      height=200,
      decimals=null,
      span=span,
      fill=0,
      legend_show=true,
      legend_rightSide=false,
      format='short',
      query=|||
        sum(increase(net_conntrack_dialer_conn_failed_total{%(selector)s}[%(interval)s])) > 0
      ||| % config,
      legendFormat='Failed Connections'
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_compactions_skipped_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Skipped compactions - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_engine_query_log_failures_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed Query logs - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_wal_corruptions_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='WAL corruptions - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_wal_writes_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed WAL writes - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_wal_truncations_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed WAL truncations - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_head_truncations_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed head truncations - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_head_series_not_found{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Head Series Not Found - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_compactions_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed compactions - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_checkpoint_deletions_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed checkpoint deletions - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_retention_cutoffs_failures_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Retention Cutoff Failures - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_checkpoint_creations_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed checkpoint creations - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_target_scrape_pools_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed scrape pool creations - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_target_scrape_pool_reloads_failed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed scrape loop reloads - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_reloads_failures_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed to reload block data from disk - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_sd_gce_refresh_failures_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed GCE SD - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_rule_evaluation_failures_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Failed Rule evaluations - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_rule_group_iterations_missed_total{%(selector)s}[%(interval)s])) > 0
        ||| % config,
        legendFormat='Missed Rule evaluations - {{ pod }}',
      )
    ) + {
      lines: false,
      points: true,
      pointradius: 2,
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        max: false,
        min: false,
        total: false,
      },

    },


  tsdbCutoffs(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
    };

    commonPanels.timeseries(
      title='Retention Cutoffs',
      description='blocks were deleted because the maximum time / size limit was exceeded',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='short',
      query=|||
        increase(prometheus_tsdb_time_retentions_total{%(selector)s}[5m])
      ||| % config,
      legendFormat='Time - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          increase(prometheus_tsdb_size_retentions_total{%(selector)s}[5m])
        ||| % config,
        legendFormat='Size - {{ pod }}',
      )
    ),

  tsdbCompactions(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
    };

    commonPanels.timeseries(
      title='Compactions',
      description='Compactions events and duration',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='short',
      query=|||
        increase(prometheus_tsdb_compactions_total{%(selector)s}[5m])
      ||| % config,
      legendFormat='Compaction event - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          rate(prometheus_tsdb_compaction_duration_seconds_sum{%(selector)s}[2m])
        ||| % config,
        legendFormat='Compaction duration - {{ pod }}',
      )
    ) + {
      seriesOverrides: [
        {
          alias: '/^Compaction duration - .*/',
          yaxis: 2,
          format: 's',
          linewidth: 1,
        },
      ],
    } + {
      yaxes: [
        {
          format: 'short',
          label: 'events',
          logBase: 1,
          max: null,
          min: 0,
          show: true,
        },
        {
          format: 's',
          label: 'duration',
          logBase: 1,
          max: null,
          min: 0,
          show: true,
        },
      ],
    },


  averageWalFsync(selector, span=2)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      interval: '2h',
    };

    commonPanels.timeseries(
      title=std.format('WAL Average fsync - %s', config.interval),
      description='Duration of WAL fsync',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='s',
      query=|||
        rate(prometheus_tsdb_wal_fsync_duration_seconds_sum{%(selector)s}[%(interval)s])
        /
        rate(prometheus_tsdb_wal_fsync_duration_seconds_count{%(selector)s}[%(interval)s])
      ||| % config,
      legendFormat='Fsync latency - {{ pod }}'
    ),

  averageCompactionTime(selector, span=2)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
      interval: '2h',
    };

    commonPanels.timeseries(
      title=std.format('Compaction Average time - %s', config.interval),
      description='Duration of Compaction event',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='s',
      query=|||
        rate(prometheus_tsdb_compaction_duration_seconds_sum{%(selector)s}[%(interval)s])
        /
        rate(prometheus_tsdb_compaction_duration_seconds_count{%(selector)s}[%(interval)s])
      ||| % config,
      legendFormat='Compaction duration - {{ pod }}'
    ),


  tsdbBlocksReload(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
    };

    commonPanels.timeseries(
      title='Reload block data from disk',
      description='Number of times the database reloaded block data from disk',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='short',
      query=|||
        irate(prometheus_tsdb_reloads_total{%(selector)s}[2m])
      ||| % config,
      legendFormat='Total Blocks reload - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          irate(prometheus_tsdb_reloads_failures_total{%(selector)s}[2m])
        ||| % config,
        legendFormat='Blocks reload failures - {{ pod }}',
      )
    ) + {
      seriesOverrides: [
        {
          alias: '/^Total blocks reload - .*/',
          zaxis: 0,
          color: '#73BF69',
        },
        {
          alias: '/^Blocks reload failures - .*/',
          zaxis: 1,
          fill: 0,
          color: '#C4162A',
        },
      ],
    },

  activeDataBlocks(selector, span=4)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Active Blocks',
      description='Number of currently loaded data blocks',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      legend_rightSide=false,
      format='short',
      query=|||
        prometheus_tsdb_blocks_loaded{%(selector)s,pod=~"$prometheus"}
      ||| % config,
      legendFormat='Active Blocks - {{ pod }}'
    ),


  largetsSampleJobsInstance(span=4, topk=10)::
    local config = {
      topk: topk,
    };

    commonPanels.timeseries(
      title=std.format('Largest %s Scrapes job/instance', topk),
      height=300,
      decimals=null,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      format='short',
      query=|||
        topk(%(topk)s, max(avg_over_time(scrape_samples_scraped{}[1h])) by (job, instance))
      ||| % config,
      legendFormat='{{ job }}/{{ instance }}'
    ),

  scrapeDurationWorstJobsInstances(span=4, topk=10)::
    local config = {
      topk: topk,
    };

    commonPanels.timeseries(
      title=std.format('Scrape Time worst %s job/instance', topk),
      height=300,
      decimals=null,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      format='s',
      query=|||
        topk(%(topk)s, max(avg_over_time(scrape_duration_seconds{}[1h])) by (job, instance))
      ||| % config,
      legendFormat='{{ job }}/{{ instance }}'
    ),

  scrapesPercentile(selector, span=4, percentile='0.99')::
    local config = {
      selector: selector,
      percentile: percentile,
    };

    commonPanels.timeseries(
      title=std.format('%s percentile of intervals between scrapes', percentile),
      description='Actual intervals between scrapes',
      height=300,
      decimals=5,
      span=span,
      fill=1,
      legend_show=true,
      legend_rightSide=false,
      format='s',
      query=|||
        prometheus_target_interval_length_seconds{quantile="%(percentile)s", %(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='{{ interval }}/{{ pod }}'
    ),

  headTimeSeries(selector, span=4)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Head TimeSeries',
      description='Number of timeseries in the head chunk (last 0-2 hours)',
      yAxisLabel='number of timeseries',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      format='short',
      query=|||
        prometheus_tsdb_head_series{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='{{ pod }}'
    ),


  seriesCreatedRemoved(selector, span=4)::
    local config = {
      selector: std.format('%s, pod=~"$prometheus"', selector),
    };

    commonPanels.timeseries(
      title='Series Created / Removed',
      description='Series Created and Removed over 5m',
      height=200,
      span=span,
      decimals=null,
      fill=1,
      legend_show=false,
      query=|||
        sum(increase(prometheus_tsdb_head_series_created_total{%(selector)s}[5m]))
      ||| % config,
      legendFormat='Created - {{ pod }}',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          sum(increase(prometheus_tsdb_head_series_removed_total{%(selector)s}[5m]))
        ||| % config,
        legendFormat='Removed - {{ pod }}',
        intervalFactor=1,
      )
    )
    .resetYaxes()
    .addYaxis(
      format='short',
      min=null,
      max=null,
      label='Number of Series',
    ) + {
      seriesOverrides: [
        {
          alias: '/Removed - .*/',
          transform: 'negative-Y',
        },
      ],
    },

  headTimeSeriesRates(selector, interval='$__interval', span=4)::
    local config = {
      selector: selector,
      interval: interval,
    };

    commonPanels.timeseries(
      title='Head TimeSeries Appended/s',
      description='Number of timeseries appended to the head chunk (last 0-2 hours)',
      yAxisLabel='number of timeseries',
      height=200,
      span=span,
      decimals=null,
      fill=1,
      legend_show=false,
      format='cps',
      query=|||
        rate(prometheus_tsdb_head_samples_appended_total{%(selector)s, pod=~"$prometheus"}[%(interval)s])
      ||| % config,
      legendFormat='rate - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          prometheus_tsdb_head_active_appenders{%(selector)s, pod=~"$prometheus"}
        ||| % config,
        legendFormat='active appenders - {{ pod }}',
        intervalFactor=1,
      )
    ) + {
      seriesOverrides: [
        {
          alias: '/active appenders - .*/',
          bars: true,
          lines: false,
          yaxis: 2,
        },
      ],
      yaxes: [
        {
          format: 'cps',
          label: 'number of timeseries',
          logBase: 1,
          max: null,
          min: 0,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          max: null,
          min: 0,
          decimals: 0,
          label: 'active appenders',
          show: true,
        },
      ],
    },

  headChunks(selector, span=4)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Head Chunks',
      description='Total number of chunks in the head block',
      height=200,
      decimals=null,
      span=span,
      fill=1,
      legend_show=false,
      format='short',
      query=|||
        prometheus_tsdb_head_chunks{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='{{ pod }}'
    ),

  headChunksOperations(selector, span=4)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Head Chunks Ops',
      description='Rate of chunks Created/Removed in the head block',
      height=200,
      decimals=null,
      intervalFactor=1,
      span=span,
      fill=1,
      legend_show=true,
      format='ops',
      query=|||
        irate(prometheus_tsdb_head_chunks_created_total{%(selector)s, pod=~"$prometheus"}[1m])
      ||| % config,
      legendFormat='Created - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          irate(prometheus_tsdb_head_chunks_removed_total{%(selector)s, pod=~"$prometheus"}[1m])
        ||| % config,
        legendFormat='Removed - {{ pod }}',
        intervalFactor=1,
      )
    ),


  memoryUsage(selector, span=6)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Prometheus GOlang Memory Usage',
      description='Memory usage for prometheus process, including GO heap and GC',
      height=200,
      span=span,
      decimals=null,
      fill=0,
      legend_show=false,
      format='bytes',
      query=|||
        process_resident_memory_bytes{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='RSS - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          prometheus_local_storage_target_heap_size_bytes{%(selector)s, pod=~"$prometheus"}
        ||| % config,
        legendFormat='Target heap size - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          go_memstats_next_gc_bytes{%(selector)s, pod=~"$prometheus"}
        ||| % config,
        legendFormat='Next GC - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          go_memstats_alloc_bytes{%(selector)s, pod=~"$prometheus"}
        ||| % config,
        legendFormat='Allocated - {{ pod }}',
      )
    )
    .addTarget(
      promQuery.target(
        |||
          rate(prometheus_tsdb_head_gc_duration_seconds_sum{%(selector)s, pod=~"$prometheus"}[4h])
          /
          rate(prometheus_tsdb_head_gc_duration_seconds_count{%(selector)s, pod=~"$prometheus"}[4h])
        ||| % config,
        legendFormat='Average GC Latency',
      )
    ) + {
      seriesOverrides: [
        {
          alias: 'Average GC Latency',
          color: '#C4162A',
          fill: 0,
          lineWidth: 4,
          zindex: -3,
          yaxis: 2,
        },
      ],
    } {
      yaxes: [
        {
          format: 'bytes',
          label: '',
          logBase: 1,
          max: null,
          min: 0,
          show: true,
        },
        {
          format: 's',
          label: 'duration',
          logBase: 1,
          max: null,
          min: 0,
          show: true,
        },
      ],
    },

  tsdbStoragetBlockSize(selector, span=3)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='Block Size',
      description='The number of bytes that are currently used for local storage by all blocks',
      height=200,
      span=span,
      decimals=null,
      fill=0,
      legend_show=false,
      format='bytes',
      query=|||
        prometheus_tsdb_storage_blocks_bytes_total{%(selector)s, pod=~"$prometheus"} or 
          prometheus_tsdb_storage_blocks_bytes{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='TSDB Block Size - {{ pod }}'
    ),

  fileDescriptors(selector, span=3)::
    local config = {
      selector: selector,
    };

    commonPanels.timeseries(
      title='File Descriptors',
      description='Open and Max file descriptors as seen by the GO processs',
      height=200,
      span=span,
      decimals=null,
      fill=0,
      legend_show=false,
      format='short',
      query=|||
        process_max_fds{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      legendFormat='Max - {{ pod }}'
    )
    .addTarget(
      promQuery.target(
        |||
          process_open_fds{%(selector)s, pod=~"$prometheus"}
        ||| % config,
        legendFormat='Open - {{ pod }}',
      )
    ) + {
      seriesOverrides: [
        {
          alias: '/Max - .*/',
          color: '#C4162A',
          fill: 1,
          zindex: -3,
        },
        {
          alias: '/Open - .*/',
          color: '#73BF69',
          fill: 0,
          zindex: 0,
        },
      ],
    },

  skippedScrapes(selector, span=2)::
    local config = {
      selector: selector,
    };

    commonPanels.singlestat(
      title='Skipped Scrapes',
      description='Sum of all different failures for Scrapes',
      span=span,
      query=|||
        sum by (pod) (prometheus_target_scrapes_exceeded_sample_limit_total{%(selector)s, pod=~"$prometheus"}) + 
        sum by (pod) (prometheus_target_scrapes_sample_duplicate_timestamp_total{%(selector)s, pod=~"$prometheus"}) + 
        sum by (pod) (prometheus_target_scrapes_sample_out_of_bounds_total{%(selector)s, pod=~"$prometheus"}) + 
        sum by (pod) (prometheus_target_scrapes_sample_out_of_order_total{%(selector)s, pod=~"$prometheus"}) 
      ||| % config,
      decimals=0,
      format='short'
    ),

  scrapeCacheFlush(selector, span=2)::
    local config = {
      selector: selector,
    };

    commonPanels.singlestat(
      title='Scrape Cache Forced Flush',
      description='How many times a scrape cache was flushed due to getting big while scrapes are failing',
      span=span,
      query=|||
        sum by (pod) (prometheus_target_scrapes_cache_flush_forced_total{%(selector)s, pod=~"$prometheus"}) 
      ||| % config,
      decimals=0,
      format='short'
    ),

  averageChunkSize(selector, span=2)::
    local config = {
      selector: selector,
    };

    commonPanels.singlestat(
      title='AVG Chunk Size',
      description='Average Final size of chunks on their first compaction',
      span=span,
      query=|||
        prometheus_tsdb_compaction_chunk_size_bytes_sum{%(selector)s, pod=~"$prometheus"}/prometheus_tsdb_compaction_chunk_size_bytes_count{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      decimals=0,
      format='bytes'
    ),

  averageChunkSamples(selector, span=2)::
    local config = {
      selector: selector,
    };

    commonPanels.singlestat(
      title='AVG Samples in Chunk',
      description='Average Final number of samples on their first compaction',
      span=span,
      query=|||
        prometheus_tsdb_compaction_chunk_samples_sum{%(selector)s, pod=~"$prometheus"}/prometheus_tsdb_compaction_chunk_samples_count{%(selector)s, pod=~"$prometheus"}
      ||| % config,
      decimals=0,
      format='short'
    ),

}
