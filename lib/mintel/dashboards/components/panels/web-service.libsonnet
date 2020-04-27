local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local haproxyPanels = import 'components/panels/haproxy.libsonnet';
{

  overview(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([

      commonPanels.gauge(
        title='Instances Up',
        description='Number of instances running as a percentage (should be 100%)',
        instant=true,
        format='percent',
        span=2,
        valueFontSize='50%',
        colors=[
          '#d44a3a',
          'rgba(237, 129, 40, 0.89)',
          '#299c46',
        ],
        query=|||
          100 * min(
            kube_deployment_status_replicas_available{deployment="%(serviceSelectorValue)s"})
            without (instance, pod)
            /
            max(kube_deployment_spec_replicas{deployment="%(serviceSelectorValue)s"}) 
           without (instance, pod)
        ||| % config,
      ),

      commonPanels.timeseries(
        title='Instances Running Over Time',
        description='Number of instances running over time',
        span=6,
        legend_show=false,
        query=|||
          sum(up{%(serviceSelectorKey)s="%(serviceSelectorValue)s", namespace="$namespace"})
        ||| % config,
      ),

      commonPanels.singlestat(
        title='RPS (Total)',
        description='Requests per second (all http-status)',
        colorBackground=true,
        instant=true,
        format='rps',
        span=2,
        query=|||
          sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[2m]))
        ||| % config,
      ),

      commonPanels.singlestat(
        title='RPS (Errors)',
        description='Requests per second (HTTP 500 errors)',
        colorBackground=true,
        instant=true,
        format='rps',
        span=2,
        query=|||
          sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*",code="5xx"}[2m]))
        ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),
}
