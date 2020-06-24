local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{

  containerResourcesPanel(podSelectorValue, containerName='main', startRow=1000)::
    local config = {
      podSelectorValue: podSelectorValue,
      containerName: containerName,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Per Instance CPU',
        yAxisLabel='CPU Usage',
        span=6,
        legend_show=false,
        query=|||
          sum(
            rate(
              container_cpu_usage_seconds_total{namespace="$namespace", pod=~"%(podSelectorValue)s.*", container="%(containerName)s"}[5m])) by (pod)
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        span=6,
        legend_show=false,
        query=|||
          container_memory_usage_bytes{namespace="$namespace", pod=~"%(podSelectorValue)s.*", container="%(containerName)s"}
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
}
