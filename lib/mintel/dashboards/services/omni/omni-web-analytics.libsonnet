local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{

  apiServiceLatency(serviceSelectorKey='service', serviceSelectorValue='${service}', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    layout.grid([

      commonPanels.latencyTimeseries(
        title='API Service Latency',
        description='Percentile Latency For Analytics API Service',
        yAxisLabel='Time',
        format='s',
        legend_show=true,
        span=span,
        nullPointMode='null as zero',
        height=300,
        query=|||
          mintel:http_request_duration_seconds_quantile:95{%(serviceSelectorKey)s="%(serviceSelectorValue)s", analytics_type=~"$analytics_type"}
        ||| % config,
        legendFormat='p95 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
        intervalFactor=2,
      )
      .addTarget(
        promQuery.target(
          |||
            mintel:http_request_duration_seconds_quantile:75{%(serviceSelectorKey)s="%(serviceSelectorValue)s", analytics_type=~"$analytics_type"}
          ||| % config,
          legendFormat='p75 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
          intervalFactor=2,
        )
      )
      .addTarget(
        promQuery.target(
          |||
            mintel:http_request_duration_seconds_quantile:50{%(serviceSelectorKey)s="%(serviceSelectorValue)s", analytics_type=~"$analytics_type"}
          ||| % config,
          legendFormat='p50 {{ %(serviceSelectorKey)s }}/{{ analytics_type }}' % (config),
          intervalFactor=2,
        )
      ),
    ]),

  elasticSearchResponses(serviceSelectorKey='service', serviceSelectorValue='${service}', span=12)::
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
        nullPointMode='null as zero',
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

  omniWebDashboardRequest(span=12)::

    layout.grid([

      commonPanels.latencyTimeseries(
        title='Dashboard Request Time',
        description='Dashboard Request Time By Dashboard ID',
        yAxisLabel='Time',
        format='s',
        legend_show=true,
        span=span,
        nullPointMode='null as zero',
        height=450,
        query=|||
          sum(rate(django_widget_request_time_sum{service="$service"}[$__interval])) by (dashboard_id)
          /
          sum(rate(django_widget_request_time_count{service="$service"}[$__interval])) by (dashboard_id)
        |||,
        legendFormat='Dashboard ID: {{ dashboard_id }}',
        intervalFactor=2,
      ),
    ]),

  omniWebWidgetRequest(span=12)::

    layout.grid([

      commonPanels.latencyTimeseries(
        title='Widget Request Time',
        description='Widget Request Time By Dashboard ID',
        yAxisLabel='Time',
        format='s',
        legend_show=true,
        span=span,
        nullPointMode='null as zero',
        height=250,
        query=|||
          sum(rate(django_widget_request_time_sum{service="$service", dashboard_id="$dashboard_id"}[$__interval])) by (widget_id)
          /
          sum(rate(django_widget_request_time_count{service="$service", dashboard_id="$dashboard_id"}[$__interval])) by (widget_id)
        |||,
        legendFormat='Widget ID: {{ widget_id }}',
        intervalFactor=2,
      ),
    ]),

}
