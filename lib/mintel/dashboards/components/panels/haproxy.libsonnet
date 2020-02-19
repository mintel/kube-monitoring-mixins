local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  latencyTimeseries(serviceSelectorKey="service", serviceSelectorValue="$service", span=12)::
      local config = {
        serviceSelectorKey: serviceSelectorKey,
        serviceSelectorValue: serviceSelectorValue
    };

    commonPanels.latencyTimeseries(
      title='HAProxy Latency',
      description='Percentile Latency from HAProxy Ingress',
      yAxisLabel='Time',
      format='s',
      span=span,
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
  
}
