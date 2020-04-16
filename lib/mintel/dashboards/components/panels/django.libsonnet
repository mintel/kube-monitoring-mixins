local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local haproxyPanels = import 'components/panels/haproxy.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  requestResponsePanels(serviceSelectorKey='service', serviceSelectorValue='$service', interval='$__interval', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      interval: interval,
    };
    layout.grid([

      haproxyPanels.latencyTimeseriesPreRecorded(config.serviceSelectorKey, config.serviceSelectorValue, span=4),
      haproxyPanels.httpResponseStatusTimeseries(config.serviceSelectorKey, config.serviceSelectorValue, interval=config.interval, span=4),

      commonPanels.timeseries(
        title='App Requests by Method/View',
        yAxisLabel='Num Requests',
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
    ], cols=12, rowHeight=10, startRow=startRow),

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
