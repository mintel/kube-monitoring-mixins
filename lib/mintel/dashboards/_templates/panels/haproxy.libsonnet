local commonPanels = import '_templates/panels/common.libsonnet';
local layout = import '_templates/utils/layout.libsonnet';
{
  overview(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Latency',
        yAxisLabel='Time',
        span=12,
        legend_show=false,
        height=200,
        query=|||
          histogram_quantile(0.95, 
            sum(
              rate(
                http_backend_request_duration_seconds_bucket{backend=~"$namespace-.*$deployment-[0-9].*"}[5m]))
          by (backend,job,le))
        ||| % config,
      legendFormat='{{ backend }} - 95p',
      intervalFactor=2,
      ),

    ], cols=1, rowHeight=250, startRow=startRow+1)
}