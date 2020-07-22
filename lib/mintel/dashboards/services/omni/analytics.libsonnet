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
      title='API Service Latency',
      description='Percentile Latency For Analytics API Service',
      yAxisLabel='Time',
      format='s',
      legend_show=true,
      span=span,
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

  dashboardRequest(span=12)::

    layout.grid([

      commonPanels.latencyTimeseries(
        title='Dashboard Request Time',
        description='Dashboard Request Time by dashboard id',
        yAxisLabel='Time',
        format='s',
        legend_show=true,
        span=span,
        height=400,
        query=|||
          sum(rate(django_widget_request_time_sum{service="$service"}[$__interval])) by (dashboard_id)
          /
          sum(rate(django_widget_request_time_count{service="$service"}[$__interval])) by (dashboard_id)
        |||,
        legendFormat='Dashboard ID: {{ dashboard_id }}',
        intervalFactor=2,
      ),
    ]),

  widgetRequest(span=8)::

    layout.grid([

      commonPanels.latencyTimeseries(
        title='Widget Request Time',
        description='Widget Request Time by dashboard id',
        yAxisLabel='Time',
        format='s',
        legend_show=true,
        span=span,
        height=400,
        query=|||
          sum(rate(django_widget_request_time_sum{service="$service", dashboard_id="$dashboard_id"}[$__interval])) by (widget_id)
          /
          sum(rate(django_widget_request_time_count{service="$service", dashboard_id="$dashboard_id"}[$__interval])) by (widget_id)
        |||,
        legendFormat='Widget ID: {{ widget_id }}',
        intervalFactor=2,
      ),
    ]),

  dashboardTotalRequest(span=4)::

    layout.grid([

      commonPanels.table(
        title='Dashboard Total Requests',
        styles=[
          {
            alias: 'Namespace',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 2,
            mappingType: 1,
            pattern: 'namespace',
            thresholds: [],
            type: 'hidden',
            unit: 'short',
          },
          {
            alias: 'Dashboard',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 0,
            mappingType: 1,
            pattern: 'dashboard_id',
            thresholds: [],
            type: 'number',
            unit: 'none',
          },
          {
            alias: 'Requests',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 0,
            mappingType: 1,
            pattern: 'Value',
            thresholds: [],
            type: 'number',
            unit: 'none',
          },
          {
            alias: '',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 2,
            mappingType: 1,
            pattern: 'Time',
            thresholds: [],
            type: 'hidden',
            unit: 'short',
          },
        ],
        query=|||
          sum(widget_total_requests_total{service="$service"}) by (dashboard_id)
        |||,
        span=span,
        height=400,
        intervalFactor=1,
        legendFormat='{{ dashboard_id }}',
      )
    ]),

  widgetTotalRequest(span=4)::

    layout.grid([

      commonPanels.table(
        title='Widget Total Requests',
        styles=[
          {
            alias: 'Namespace',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 2,
            mappingType: 1,
            pattern: 'namespace',
            thresholds: [],
            type: 'hidden',
            unit: 'short',
          },
          {
            alias: 'Widget',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 0,
            mappingType: 1,
            pattern: 'widget_id',
            thresholds: [],
            type: 'number',
            unit: 'none',
          },
          {
            alias: 'Requests',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 0,
            mappingType: 1,
            pattern: 'Value',
            thresholds: [],
            type: 'number',
            unit: 'none',
          },
          {
            alias: '',
            align: 'auto',
            colorMode: null,
            colors: [
              'rgba(245, 54, 54, 0.9)',
              'rgba(237, 129, 40, 0.89)',
              'rgba(50, 172, 45, 0.97)',
            ],
            dateFormat: 'YYYY-MM-DD HH:mm:ss',
            decimals: 2,
            mappingType: 1,
            pattern: 'Time',
            thresholds: [],
            type: 'hidden',
            unit: 'short',
          },
        ],
        query=|||
          sum(widget_total_requests_total{service="$service", dashboard_id="$dashboard_id"}) by (widget_id)
        |||,
        span=span,
        height=400,
        intervalFactor=1,
        legendFormat='{{ widget_id }}',
      ),
    ]),

    dashboardRequestsRate(span=4)::

    layout.grid([

      commonPanels.singlestat(
        title='Incoming Request Volume',
        description='Requests Rate',
        colorBackground=true,
        format='rps',
        sparklineShow=true,
        span=span,
        height=400,
        query=|||
          sum(
            rate(
              widget_total_requests_total{service="$service", dashboard_id="$dashboard_id"}[$__interval]))
        |||,
      ),
    ]),

}