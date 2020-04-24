local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';

{

  podResourcesRow(namespace, pod, container='.*', title='', interval='5m', startRow=1000)::
    local config = {
      kubeletSelector: std.format('namespace="%s", pod=~"%s", image!="", job="kubelet", container=~"%s", container!="POD"', [namespace, pod, container]),
      kubeStateSelector: std.format('namespace="%s", pod=~"%s", container=~"%s", job="kube-state-metrics"', [namespace, pod, container]),
      throttlingSelector: std.format('namespace="%s", pod=~"%s", container=~"%s", job="kubelet"', [namespace, pod, container]),
      interval: interval,
      cpuTitle: std.format('Pod Cpu %s', title),
      memoryTitle: std.format('Pod Memory %s', title),
      overrides: {
        seriesOverrides: [
          {
            alias: '/Limits - .*/',
            color: '#C4162A',
            fill: 1,
            zindex: -3,
          },
          {
            alias: '/Requested - .*/',
            color: '#73BF69',
            fill: 1,
            zindex: -2,
          },
          {
            alias: '/Current - .*/',
            color: '#FADE2A',
            fill: 0,
            zindex: 1,
          },
          {
            alias: '/Current rate .*/',
            color: '#FADE2A',
            fill: 0,
            zindex: 0,
          },
          {
            alias: '/Current irate .*/',
            color: '#B877D9',
            fill: 0,
            zindex: 1,
            linewidth: 1,
          },
          {
            alias: '/Throttling - .*/',
            yaxis: 2,
            bars: true,
            lines: false,
            zindex: 2,
            color: 'rgb(232, 0, 4)',
            nullPointMode: 'null as zero',
          },
        ],
      },
    };
    layout.grid([
      commonPanels.timeseries(
        title=config.cpuTitle,
        span=6,
        decimals=null,
        format='short',
        legend_show=false,
        query=|||
          sum by (pod) (
            rate(container_cpu_usage_seconds_total{%(kubeletSelector)s}[1m])
          )
        ||| % config,
        legendFormat='Current rate 1m - {{ pod }}',
        intervalFactor=1,
      )
      .addTarget(
        promQuery.target(
          |||
            sum by (pod) (
              rate(container_cpu_usage_seconds_total{%(kubeletSelector)s}[%(interval)s])
            )
          ||| % config,
          legendFormat=std.format('Current rate %s - {{ pod }}', config.interval),
        )
      )
      .addTarget(
        promQuery.target(
          |||
            sum by (pod) (
              kube_pod_container_resource_requests{%(kubeStateSelector)s, resource="cpu"}
            )
          ||| % config,
          legendFormat='Requested - {{ pod }}',
        )
      )
      .addTarget(
        promQuery.target(
          |||
            sum by (pod) (
              kube_pod_container_resource_limits{%(kubeStateSelector)s, resource="cpu"}
            )
          ||| % config,
          legendFormat='Limits - {{ pod }}',
        )
      )
      .addTarget(
        promQuery.target(
          |||
            100 *
            sum(increase(container_cpu_cfs_throttled_periods_total{%(throttlingSelector)s}[5m])) by (container,pod)
            /
            sum(increase(container_cpu_cfs_periods_total{%(throttlingSelector)s}[5m])) by (container,pod)
          ||| % config,
          legendFormat='Throttling - {{ pod }}',
          intervalFactor=1,
        )
      ) + config.overrides +
      {
        yaxes: [
          {
            format: 'short',
            label: 'CPU Cores Usage',
            logBase: 1,
            max: null,
            min: 0,
            show: true,
          },
          {
            format: 'percent',
            label: 'CPU Throttling',
            logBase: 1,
            max: '100',
            min: 0,
            show: true,
            decimals: 3,
          },
        ],
      },

      commonPanels.timeseries(
        title=config.memoryTitle,
        span=6,
        decimals=null,
        format='bytes',
        legend_show=false,
        query=|||
          sum by(pod) (container_memory_working_set_bytes{%(kubeletSelector)s})
        ||| % config,
        legendFormat='Current - {{ pod }}',
        intervalFactor=1,
      )
      .addTarget(
        promQuery.target(
          |||
            sum by (pod) (
              kube_pod_container_resource_requests{%(kubeStateSelector)s, resource="memory"}
            )
          ||| % config,
          legendFormat='Requested - {{ pod }}',
        )
      )
      .addTarget(
        promQuery.target(
          |||
            sum by (pod) (
              kube_pod_container_resource_limits{%(kubeStateSelector)s, resource="memory"}
            )
          ||| % config,
          legendFormat='Limits - {{ pod }}',
        )
      )
      .addTarget(
        promQuery.target(
          |||
            sum by(pod) (container_memory_cache{%(kubeletSelector)s})
          ||| % config,
          legendFormat='Cache - {{ pod }}',
        )
      ) + config.overrides,
    ], cols=2, rowHeight=10, startRow=startRow),

}
