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
          100 * (kube_deployment_status_replicas_available{namespace=~"$namespace"}) /(kube_deployment_spec_replicas{namespace=~"$namespace"})
          or
          100 * (kube_statefulset_status_replicas_current{namespace=~"$namespace"}) /(kube_statefulset_status_replicas{namespace=~"$namespace"})

        ||| % config,
      ),

      commonPanels.singlestat(
        title='Incoming Request Volume',
        description='Requests per second (all http-status)',
        colorBackground=true,
        format='rps',
        sparklineShow=true,
        span=4,
        query=|||
          sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[$__interval]))
        ||| % config,
      ),
      commonPanels.singlestat(
        title='Incoming Success Rate',
        description='Percentage of successful (non http-5xx) requests',
        colorBackground=true,
        format='percent',
        sparklineShow=true,
        thresholds="99,95",
        colors=[
          '#d44a3a',
          'rgba(237, 129, 40, 0.89)',
          '#299c46',
        ],
        span=4,
        query=|||
          100 * (sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{code!~"5.*", backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[$__interval]))
          /
          sum(
            rate(
              haproxy:haproxy_backend_http_responses_total:counter{backend=~"$namespace-.*%(serviceSelectorValue)s-[0-9].*"}[$__interval])))
        ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),
}
