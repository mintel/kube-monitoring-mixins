local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  overview(serviceSelectorKey="service", serviceSelectorValue, startRow)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Operation Rate',
        yAxisLabel='Operations/sec',
        query=|||
          sum(rate(redis_commands_total{%(serviceSelectorKey)s=~"%(serviceSelectorValue)s"}[$__interval])) by (service)
        ||| % config,
        legendFormat='{{ service }}',
        intervalFactor=1,
      ),

      commonPanels.latencyTimeseries(
        title='Response Time',
        description='Duration of response (high = bad)',
        legend_show=false,
        query=|||
          sum(rate(redis_commands_duration_seconds_total{%(serviceSelectorKey)s=~"%(serviceSelectorValue)s"}[$__interval])) 
          /
          sum(rate(redis_commands_total{%(serviceSelectorKey)s=~"%(serviceSelectorValue)s"}[$__interval]))
        ||| % config,
        intervalFactor=2,
      ),


      commonPanels.timeseries(
        title='Cache Hit Ratio',
        description='A low cache-hit ratio can indicate issues such as high eviction rate, no usage, no key in cache',
        legend_show=false,
        format='percent',
        query=|||
          (rate(redis_keyspace_hits_total[$__interval]) /
          (rate(redis_keyspace_misses_total[$__interval]) + rate(redis_keyspace_hits_total[$__interval]))) * 100
        ||| % config,
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Connected Clients / Max Clients Ratio',
        legend_show=false,
        format='percent',
        query=|||
          (redis_connected_clients / redis_config_maxclients) * 100
        ||| % config,
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Current Memory / Max Memory Ratio',
        legend_show=false,
        format='percent',
        query=|||
          (redis_memory_used_bytes / redis_memory_max_bytes) * 100
        ||| % config,
        intervalFactor=2,
      ),


      commonPanels.timeseries(
        title='Evicted Keys Ratio',
        legend_show=false,
        format='percent',
        query=|||
          (sum(rate(redis_evicted_keys_total[$__interval])) / sum(redis_db_keys)) * 100
        ||| % config,
        intervalFactor=2,
      ),

    ], cols=3, rowHeight=10, startRow=startRow),
 
}
