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
      legend_show=true,
      height=300,
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

  latencyTimeseriesPreRecorded(serviceSelectorKey='service', serviceSelectorValue='$service', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    commonPanels.latencyTimeseries(
      title='HAProxy Latency',
      description='Percentile Latency from HAProxy Ingress',
      yAxisLabel='Time',
      format='s',
      span=span,
      legend_show=true,
      height=300,
      query=|||
        haproxy:http_backend_request_seconds_quantile:95{mintel_com_service="$namespace_%(serviceSelectorValue)s"}
      ||| % config,
      legendFormat='p95 {{ backend }}',
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          haproxy:http_backend_request_seconds_quantile:75{mintel_com_service="$namespace_%(serviceSelectorValue)s"}
        ||| % config,
        legendFormat='p75 {{ backend }}',
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          haproxy:http_backend_request_seconds_quantile:50{mintel_com_service="$namespace_%(serviceSelectorValue)s"}
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
      legend_show=true,
      height=300,
      query=|||
        sum(
          rate(
            haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]
          )
        ) by (code)
      ||| % config,
      legendFormat='{{ code }}',
      intervalFactor=2,
    ),


  httpBackendRequestsPerSecond(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    commonPanels.singlestat(
      title='Incoming Request Volume',
      description='Requests per second (all http-status)',
      colorBackground=true,
      format='rps',
      sparklineShow=true,
      span=span,
      query=|||
        sum(
          rate(
            haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[$__interval]))
      ||| % config,
    ),

  httpBackendSuccessRatioPercentage(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    commonPanels.singlestat(
      title='Incoming Success Rate',
      description='Percentage of successful (non http-5xx) requests',
      colorBackground=true,
      format='percent',
      sparklineShow=true,
      thresholds='99,95',
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      span=span,
      query=|||
        100 - haproxy:haproxy_backend_http_error_rate:percentage:1m{mintel_com_service="$namespace_%(serviceSelectorValue)s"}
      ||| % config,
    ),
}
