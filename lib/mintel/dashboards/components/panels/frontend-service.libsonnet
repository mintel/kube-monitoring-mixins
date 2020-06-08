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

      commonPanels.timeseries(
        title='Workloads Status',
        description='Percentage of instances up (by workload)',
        span=4,
        max=100,
        format='percent',
        legend_show=false,
        // Fix legendFormat to display deployment/statefulset (needs relabel)
        thresholds=[
          {'value': 50,
          'colorMode': 'critical',
          'op': 'lt',
          'fill': true,
          'line': true
        }],
        query=|||
          sum by (deployment, statefulset)
            (
              100 * (kube_deployment_status_replicas_available{namespace=~"$namespace"}) / (kube_deployment_spec_replicas{namespace=~"$namespace"})
              or
              100 * (kube_statefulset_status_replicas_ready{namespace=~"$namespace"}) / (kube_statefulset_status_replicas{namespace=~"$namespace"})
            )
        ||| % config,
      ),

      haproxyPanels.httpBackendRequestsPerSecond(config.serviceSelectorKey, config.serviceSelectorValue),
      haproxyPanels.httpBackendSuccessRatioPercentage(config.serviceSelectorKey, config.serviceSelectorValue),
    ], cols=12, rowHeight=10, startRow=startRow),
}
