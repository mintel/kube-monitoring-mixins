local commonPanels = import '_templates/panels/common.libsonnet';
local layout = import '_templates/utils/layout.libsonnet';
local promQuery = import '_templates/utils/prom_query.libsonnet';
{
  overview(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Latency',
        description='Percentile Latency',
        yAxisLabel='Time',
        span=12,
        legend_show=false,
        height=200,
        query=|||
          histogram_quantile(0.95, 
            sum(
              rate(
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*$deployment-[0-9].*"}[5m]))
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
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*$deployment-[0-9].*"}[5m]))
            by (backend,job,le))
          |||,
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
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*$deployment-[0-9].*"}[5m]))
            by (backend,job,le))
          |||,
          legendFormat='p50 {{ backend }}',
          intervalFactor=2,
        )
      ),
    ], cols=1, rowHeight=250, startRow=startRow+1)
}