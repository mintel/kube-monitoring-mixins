local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';
{
  overview(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue
    };
    layout.grid([

      commonPanels.timeseries(
        title='Pods Available',
        span=4,
        legend_show=false,
        query=|||
          sum(up{%(serviceSelectorKey)s="%(serviceSelectorValue)s", namespace="$namespace"})
      ||| % config,
      ),

      commonPanels.singlestat(
        title='2xx',
        span=2,
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"2.+", namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='3xx',
        span=2,
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"3.+", namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='4xx',
        span=2,
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"4.+", namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='5xx',
        span=2,
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"5.+", namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
      ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),

  requestResponsePanels(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue
    };
    layout.grid([
      commonPanels.timeseries(
        title='Request Latency',
        yAxisLabel='Time',
        query=|||
          histogram_quantile(0.50, 
            sum(rate(
              django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s",view!~"prometheus-django-metrics|healthcheck"}[5m])
            ) by (job, le)
          )
        ||| % config,
        legendFormat='{{ quantile=50 }}',
        legend_show=false,
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Response Status',
        yAxisLabel='Num Responses',
        query=|||
         sum(
            rate(
                django_http_responses_total_by_status_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s", view!~"prometheus-django-metrics|healthcheck"}[5m])) by(status)
        ||| % config,
        legendFormat='{{ status }}',
        legend_show=false,
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Requests by Method',
        yAxisLabel='Num REquests',
        query=|||
         sum(
            irate(
              django_http_requests_total_by_view_transport_method_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s",view!~"prometheus-django-metrics|healthcheck"}[5m]))
          by(method, view)
       ||| % config,
        legendFormat='{{ method }}/{{ view }}',
        legend_show=false,
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
    
  resourcePanels(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue
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
              django_http_responses_total_by_status_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s", view!~"prometheus-django-metrics|healthcheck"}[5m]))
          by(status)
        ||| % config,
        legendFormat='{{ status }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        span=6,
        legend_show=false,
        query=|||
          container_memory_usage_bytes{container_name="main", pod_name=~"$service-.*"}
        ||| % config,
        legendFormat='{{ pod_name }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),

  databaseOps(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue
    };
    layout.grid([
      commonPanels.timeseries(
        title='Database Operations',
        yAxisLabel='Num Operations',
        span=12,
        query=|||
          sum(rate(django_db_execute_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[1m])) by (vendor)
        ||| % config,
        legendFormat='{{ vendor }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
}