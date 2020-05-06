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
        title='Workloads',
        description='Number of instances running over time',
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
          100 * (kube_deployment_status_replicas_available{namespace=~"$namespace"}) /(kube_deployment_spec_replicas{namespace=~"$namespace"})
          or
          100 * (kube_statefulset_status_replicas_current{namespace=~"$namespace"}) /(kube_statefulset_status_replicas{namespace=~"$namespace"})

        ||| % config,
      ),

      commonPanels.singlestat(
        title='RPS (Total)',
        description='Requests per second (all http-status)',
        colorBackground=true,
        format='rps',
        span=4,
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
        format='rps',
        span=4,
        query=|||
          sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*",code="5xx"}[2m]))
        ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),
}
