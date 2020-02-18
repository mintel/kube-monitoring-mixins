local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  requestResponsePanels(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([

      commonPanels.latencyTimeseries(
        title='App Request Latency',
        description='Percentile Latency',
        yAxisLabel='Time',
        format='s',
        span=4,
        legend_show=false,
        height=200,
        query=|||
          histogram_quantile(0.95,
            sum(
              rate(
                django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
          by (service, le))
        ||| % config,
        legendFormat='p95 {{ service }}',
        intervalFactor=2,
      )
      .addTarget(
        promQuery.target(
          |||
            histogram_quantile(0.75,
            sum(
              rate(
                django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
            by (service, le))
          ||| % config,
          legendFormat='p75 {{ service }}',
          intervalFactor=2,
        )
      )
      .addTarget(
        promQuery.target(
          |||
            histogram_quantile(0.50,
            sum(
              rate(
                django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
            by (service, le))
          ||| % config,
          legendFormat='p50 {{ service }}',
          intervalFactor=2,
        ),
      ),

      commonPanels.timeseries(
        title='App Response Status',
        yAxisLabel='Num Responses',
        query=|||
          sum(
             rate(
                 django_http_responses_total_by_status_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m])) by(status)
        ||| % config,
        legendFormat='{{ status }}',
        legend_show=false,
        intervalFactor=2,
      ),
      commonPanels.timeseries(
        title='App Requests by Method',
        yAxisLabel='Num REquests',
        query=|||
          sum(
             irate(
               django_http_requests_total_by_view_transport_method_total{namespace=~"$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[5m]))
           by(method, view)
        ||| % config,
        legendFormat='{{ method }}/{{ view }}',
        legend_show=false,
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),

  resourcePanels(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
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
              container_cpu_usage_seconds_total{namespace="$namespace", pod=~"$service.*", container="main"}[5m])) by (pod)
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        span=6,
        legend_show=false,
        query=|||
          container_memory_usage_bytes{namespace="$namespace", pod=~"$service-.*", container="main"}
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),

  databaseOps(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([
      commonPanels.timeseries(
        title='DB Operations',
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