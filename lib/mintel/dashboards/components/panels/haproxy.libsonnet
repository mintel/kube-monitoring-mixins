local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  latencyTimeseries(serviceSelectorKey='service', serviceSelectorValue='$service', interval='5m', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      interval: interval,
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
              http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]))
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
              http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]))
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
              http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]))
          by (backend,job,le))
        ||| % config,
        legendFormat='p50 {{ backend }}',
        intervalFactor=2,
      )
    ),

  httpResponseStatusTimeseries(serviceSelectorKey='service', serviceSelectorValue='$service', interval='5m', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      interval: interval,
    };

    commonPanels.timeseries(
      title='HAProxy Responses',
      description='HTTP Responses from HAProxy Ingress for backend %(serviceSelectorValue)s' % config,
      yAxisLabel='Num Responses',
      span=span,
      legend_show=false,
      height=200,
      query=|||
        sum(
          rate(
            haproxy:haproxy_backend_http_responses_total:labeled{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]
          )
        ) by (code)
      ||| % config,
      legendFormat='{{ code }}',
      intervalFactor=2,
    ),
}
