local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{

  apiServiceLatency(serviceSelectorKey='service', serviceSelectorValue='$service', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    layout.grid([

    commonPanels.latencyTimeseries(
      title='API Server Latency',
      description='Percentile Latency For Analytics API Server',
      yAxisLabel='Time',
      format='s',
      legend_show=true,
      span=span,
      height=300,
      query=|||
        histogram_quantile(0.95,
          sum(
            rate(
              http_request_duration_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
        by (service, analytics_type, le))
      ||| % config,
      legendFormat='p95 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.75,
          sum(
            rate(
              http_request_duration_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
          by (service, analytics_type, le))
        ||| % config,
        legendFormat='p75 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.50,
          sum(
            rate(
              http_request_duration_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
          by (service, analytics_type, le))
        ||| % config,
        legendFormat='p50 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
        intervalFactor=2,
      )
    ),
  ]),

  elasticSearchResponses(serviceSelectorKey='service', serviceSelectorValue='$service', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    layout.grid([

    commonPanels.latencyTimeseries(
      title='ElasticSearch Response Latency',
      description='Percentile Latency For Analytics ElasticSearch Responses',
      yAxisLabel='Time',
      format='s',
      legend_show=true,
      span=span,
      height=300,
      query=|||
        histogram_quantile(0.95,
          sum(
            rate(
              omni_analytics_es_request_processing_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
        by (service, analytics_type, le))
      ||| % config,
      legendFormat='p95 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.75,
          sum(
            rate(
              omni_analytics_es_request_processing_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
          by (service, analytics_type, le))
        ||| % config,
        legendFormat='p75 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.50,
          sum(
            rate(
              omni_analytics_es_request_processing_seconds_bucket{namespace="$namespace", analytics_type=~"$analytics_type", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
          by (service, analytics_type, le))
        ||| % config,
        legendFormat='p50 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
        intervalFactor=2,
      )
    ),
 ]),
}