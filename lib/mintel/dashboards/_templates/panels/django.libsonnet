local commonPanels = import '_templates/panels/common.libsonnet';
local layout = import '_templates/utils/layout.libsonnet';
local promQuery = import '_templates/utils/prom_query.libsonnet';
local seriesOverrides = import '_templates/utils/series_overrides.libsonnet';
{
  overview(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.singlestat(
        title='Pods Available',
        query=|||
          sum(up{service="$service", namespace="$namespace"})
      ||| % config,
      ),
      commonPanels.singlestat(
        title='2xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"2.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='3xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"3.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='4xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"4.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='5xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"5.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),

    ], cols=5, rowHeight=5, startRow=startRow),

  requestResponsePanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Request Latency',
        yAxisLabel='Time',
        query=|||
          histogram_quantile(0.50, 
            sum(rate(
              django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m])
            ) by (job, le)
          )
        ||| % config,
        legendFormat='{{ quantile=50 }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Response Status',
        yAxisLabel='Num Responses',
        query=|||
         sum(
            rate(
                django_http_responses_total_by_status_total{namespace=~"$namespace", service=~"^$service$", view!~"prometheus-django-metrics|healthcheck"}[5m])) by(status)
        ||| % config,
        legendFormat='{{ status }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Requests by Method',
        yAxisLabel='Num REquests',
        query=|||
         sum(
            irate(
              django_http_requests_total_by_view_transport_method_total{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m]))
          by(method, view)
       ||| % config,
        legendFormat='{{ method }}/{{ view }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
  resourcePanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Per Instance CPU',
        yAxisLabel='CPU Usage',
        query=|||
          sum(
            rate(
              django_http_responses_total_by_status_total{namespace=~"$namespace", service=~"^$service$", view!~"prometheus-django-metrics|healthcheck"}[5m]))
          by(status)
        ||| % config,
        legendFormat='{{ status }}',
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        query=|||
          container_memory_usage_bytes{container_name="main", pod_name=~"$service-.*"}
        ||| % config,
        legendFormat='{{ pod_name }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
  databaseOps(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.timeseries(
        title='Database Operations',
        yAxisLabel='Num Operations',
        query=|||
          sum(rate(django_db_execute_total{namespace=~"$namespace", service=~"^$service$"}[1m])) by (vendor)
        ||| % config,
        legendFormat='{{ vendor }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
}