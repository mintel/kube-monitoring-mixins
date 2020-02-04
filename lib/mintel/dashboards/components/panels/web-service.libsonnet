local commonPanels = import 'components/panels/common.libsonnet';
local haproxyPanels = import 'components/panels/haproxy.libsonnet';
local layout = import 'components/layout.libsonnet';
{

  overview(serviceSelectorKey="service", serviceSelectorValue="$service", startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue
    };
    layout.grid([

      commonPanels.timeseries(
        title='Instances Runing (Over Time)',
        description='Number of instances running over time',
        span=3,
        legend_show=false,
        query=|||
          sum(up{%(serviceSelectorKey)s="%(serviceSelectorValue)s", namespace="$namespace"})
      ||| % config,
      ),

      commonPanels.gauge(
        title='Instances Running',
        description='Number of instances running as a percentage (should be 100%)', 
        instant=true,
        format='percent',
        span=2,
        valueFontSize='50%',
        colors=[
          '#d44a3a',
          'rgba(237, 129, 40, 0.89)',
          '#299c46'
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

    haproxyPanels.latencyTimeseries(config.service, config.serviceSelectorValue, span=7)
    ], cols=12, rowHeight=10, startRow=startRow),
}