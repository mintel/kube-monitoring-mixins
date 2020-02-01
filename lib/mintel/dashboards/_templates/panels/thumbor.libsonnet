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
      commonPanels.timeseries(
        title='Pods Available',
        span=4,
        query=|||
          sum(up{job="$deployment", namespace="$namespace"})
      ||| % config,
      ),

      commonPanels.singlestat(
        title='2xx',
        span=2,
        query=|||
          sum(rate(thumbor_response_status_total{statuscode=~"2.+", namespace=~"$namespace", job="$deployment"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='3xx',
        span=2,
        query=|||
          sum(rate(thumbor_response_status_total{statuscode=~"3.+", namespace=~"$namespace", job="$deployment"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='4xx',
        span=2,
        query=|||
          sum(rate(thumbor_response_status_total{statuscode=~"4.+", namespace=~"$namespace", job="$deployment"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='5xx',
        span=2,
        query=|||
          sum(rate(thumbor_response_status_total{statuscode=~"5.+", namespace=~"$namespace", job="$deployment"}[5m]))
      ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),

  requestResponsePanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Response Time',
        yAxisLabel='Time',
        span=6,
        query=|||
          rate(
            thumbor_response_time_sum{namespace="$namespace", job="$deployment", statuscode_extension="response.time"}[5m])
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Response Status',
        yAxisLabel='Num Responses',
        span=6,
        query=|||
         sum(
            rate(
                thumbor_response_status_total{namespace=~"$namespace", job="$deployment"}[5m])) by(statuscode)
        ||| % config,
        legendFormat='{{ statuscode }}',
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
        span=6,
        legend_show=false,
        query=|||
          sum(
            rate(
              container_cpu_usage_seconds_total{namespace="$namespace", pod_name=~"$deployment.*"}[5m])) by (pod_name)
        ||| % config,
        legendFormat='{{ pod_name }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        span=6,
        legend_show=false,
        query=|||
          sum(container_memory_usage_bytes{namespace="$namespace", pod_name=~"$deployment-.*"}) by (pod_name)
        ||| % config,
        legendFormat='{{ pod_name }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=200, startRow=startRow),

  storagePanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Storage Read / Write Latency',
        yAxisLabel='',
        span=12,
        query=|||
         rate(thumbor_gcs_fetch_sum{job="$deployment"}[$__interval])
          /
          rate(thumbor_gcs_fetch_count{job="$deployment"}[$__interval])
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),
  ], cols=1, rowHeight=10, startRow=startRow),

}
