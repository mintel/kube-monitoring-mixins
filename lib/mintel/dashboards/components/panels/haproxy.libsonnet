local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  overview(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
      local config = {
        serviceSelectorKey: serviceSelectorKey,
        serviceSelectorValue: serviceSelectorValue
    };
  
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Latency',
        description='Percentile Latency',
        yAxisLabel='Time',
        format='s',
        span=12,
        legend_show=false,
        height=200,
        query=|||
          histogram_quantile(0.95, 
            sum(
              rate(
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[5m]))
          by (backend,job,le))
        ||| % config,
      legendFormat='p95 {{ backend }}',
      intervalFactor=2,
      )
      .addTarget(
        promQuery.target(
          |||
            histogram_quantile(0.75,
            sum(
              rate(
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[5m]))
            by (backend,job,le))
          ||| % config,
          legendFormat='p75 {{ backend }}',
          intervalFactor=2,
        )
      )
      .addTarget(
        promQuery.target(
          |||
            histogram_quantile(0.50,
            sum(
              rate(
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[5m]))
            by (backend,job,le))
          ||| % config,
          legendFormat='p50 {{ backend }}',
          intervalFactor=2,
        )
      ),
    ], cols=1, rowHeight=250, startRow=startRow+1)
}