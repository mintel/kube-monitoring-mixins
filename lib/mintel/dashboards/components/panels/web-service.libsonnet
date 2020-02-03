local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
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

      commonPanels.latencyTimeseries(
        title='HAProxy HTTP Responses',
        description='HAProxy HTTP Responses',
        yAxisLabel='Time',
        format='s',
        span=8,
        legend_show=false,
        height=200,
        query=|||
          sum by (backend, code)
            (irate(
              haproxy_backend_http_responses_total{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*",}[5m]))
        ||| % config,

      intervalFactor=2,
      )
    ], cols=12, rowHeight=10, startRow=startRow),
}