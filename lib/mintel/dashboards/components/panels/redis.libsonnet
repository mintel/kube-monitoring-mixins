local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  clientPanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Connected Clients',
        yAxisLabel='Clients',
        query=|||
          sum(avg_over_time(redis_connected_clients[$__interval])) by (service)
        ||| % config,
        legendFormat='{{ service }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Blocked Clients',
        description='Blocked clients are waiting for a state change event using commands such as BLPOP. Blocked clients are not a sign of an issue on their own.',
        yAxisLabel='Blocked Clients',
        query=|||
          sum(avg_over_time(redis_blocked_clients{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Connections Received',
        yAxisLabel='Connections',
        query=|||
          sum(rate(redis_connections_received_total{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),

  workload(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Operation Rate',
        yAxisLabel='Operations/sec',
        query=|||
          sum(rate(redis_commands_total{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=1,
      ),
      commonPanels.timeseries(
        title='Redis Network Out',
        format='Bps',
        query=|||
          sum(rate(redis_net_output_bytes_total{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Redis Network In',
        format='Bps',
        query=|||
          sum(rate(redis_net_input_bytes_total{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Slowlog Events',
        yAxisLabel='Events',
        query=|||
          sum(changes(redis_slowlog_last_id{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=10,
      ),
      commonPanels.timeseries(
        title='Operation Rate per Command',
        yAxisLabel='Operations/sec',
        legend_show=false,
        query=|||
          sum(rate(redis_commands_total{job="%(serviceType)s"}[$__interval])) by (cmd)
        ||| % config,
        legendFormat='{{ cmd }}',
        intervalFactor=2,
      ),
      commonPanels.latencyTimeseries(
        title='Average Operation Latency',
        legend_show=false,
        query=|||
          sum(rate(redis_commands_duration_seconds_total{job="%(serviceType)s"}[$__interval])) by (cmd)
          /
          sum(rate(redis_commands_total{job="%(serviceType)s"}[$__interval])) by (cmd)
        ||| % config,
        legendFormat='{{ cmd }}',
        intervalFactor=2,
      ),
      commonPanels.latencyTimeseries(
        title='Total Operation Latency',
        legend_show=false,
        query=|||
          sum(rate(redis_commands_duration_seconds_total{job="%(serviceType)s"}[$__interval])) by (cmd)
        ||| % config,
        legendFormat='{{ cmd }}',
        intervalFactor=2,
      ),

    ], cols=2, rowHeight=10, startRow=startRow),

  data(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Memory Used',
        format='bytes',
        query=|||
          max_over_time(redis_memory_used_bytes{job="%(serviceType)s"}[$__interval])
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Memory Used Rate of Change',
        yAxisLabel='Bytes/sec',
        format='Bps',
        query=|||
          sum(rate(redis_memory_used_bytes{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Redis RSS Usage',
        description='Depending on the memory allocator used, Redis may not return memory to the operating system at the same rate that applications release keys. RSS indicates the operating systems perspective of Redis memory usage. So, even if usage is low, if RSS is high, the OOM killer may terminate the Redis process',
        format='bytes',
        query=|||
          max_over_time(redis_memory_used_rss_bytes{job="%(serviceType)s"}[$__interval])
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Memory Fragmentation',
        description='The fragmentation ratio in Redis should ideally be around 1.0 and generally below 1.5. The higher the value, the more wasted memory.',
        query=|||
          redis_memory_used_rss_bytes{job="%(serviceType)s"} / redis_memory_used_bytes{job="%(serviceType)s"}
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Expired Keys',
        yAxisLabel='Keys',
        query=|||
          sum(rate(redis_expired_keys_total{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Keys Rate of Change',
        yAxisLabel='Keys/sec',
        query=|||
          sum(rate(redis_db_keys{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),

  replication(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Connected Secondaries',
        yAxisLabel='Secondaries',
        query=|||
          sum(avg_over_time(redis_connected_slaves{job="%(serviceType)s"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Replication Offset',
        yAxisLabel='Bytes',
        format='bytes',
        query=|||
          redis_master_repl_offset{job="%(serviceType)s"}
          - on(job) group_right
          redis_connected_slave_offset_bytes{job="%(serviceType)s"}
        ||| % config,
        legendFormat='secondary {{ slave_ip }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Resync Events',
        yAxisLabel='Events',
        query=|||
          sum(changes(redis_slave_resync_total{job="%(serviceType)s", job=~"%(serviceType)s-\\\\d\\\\d.*"}[$__interval])) by (job)
        ||| % config,
        legendFormat='{{ job }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
}
