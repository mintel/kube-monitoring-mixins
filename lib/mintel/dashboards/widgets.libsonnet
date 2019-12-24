local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local tablePanel = grafana.tablePanel;
local singlestat = grafana.singlestat;

// Common Widgets Settings
local commonGauge =
  singlestat.new(
    '',
    format='percentunit',
    datasource='$datasource',
    span=2,
    height=150,
    valueName='avg',
    valueFontSize='110%',
    colors=[
      'rgba(50, 172, 45, 0.97)',
      'rgba(237, 129, 40, 0.89)',
      'rgba(245, 54, 54, 0.9)',
    ],
    thresholds='.8, .9',
    transparent=true,
    gaugeShow=true,
    gaugeMinValue=0,
    gaugeMaxValue=1,
  );

local commonSingleStat =
  singlestat.new(
    '',
    datasource='$datasource',
    height=100,
    sparklineShow=true,
    span=2,
  );

local statusDotPanel = {
  datasource: '$datasource',
  decimals: 2,
  defaultColor: 'rgb(0, 172, 64)',
  format: 'none',
  height: 150,
  span: 2,
  mathColorValue: 'data[end]',
  mathDisplayValue: 'data[end]',
  mathScratchPad: 'data = size(data)[1] == 0 ? [NaN] : data',
  radius: '30px',
  thresholds: [
    {
      color: 'rgb(255, 142, 65)',
      value: '70',
    },
    {
      color: 'rgb(227, 228, 47)',
      value: '40',
    },
    {
      color: 'rgb(255, 0, 0)',
      value: '85',
    },
  ],
  type: 'btplc-status-dot-panel',
  targets: [],
  _nextTarget:: 0,
  addTarget(target):: self {
    local nextTarget = super._nextTarget,
    _nextTarget: nextTarget + 1,
    targets+: [target { refId: std.char(std.codepoint('A') + nextTarget) }],
  },
};

local commonGraph =
  graphPanel.new(
    '',
    datasource='$datasource',
    span=2,
    legend_show=false,
    linewidth=2,
    height=150,
  );

{

  widgets:: {
    cpuCoresRequestsGauge: commonGauge {
      title: 'CPU Cores Requests - Usage',
      description: 'Percentage of Allocatable cpu cores already requested by pods',
    }.addTarget(
      prometheus.target('sum(kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s}) / sum(kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s})' % $._config, instant=true) {
        step: 240,
      }
    ),


    cpuCoresRequestsDotPanel: statusDotPanel {
      title: 'CPU requested per node',
      description: 'Requested cpu per Node',
    }.addTarget(prometheus.target('100 * (sum by (node) (kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s}) / sum by (node) (kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s}))' % $._config, instant=true)),

    cpuIdleGraphPanel: commonGraph {
      title: 'Idle CPU',
      description: 'IDLE cpu in the cluster',
      span: 4,
      yaxes: [
        {
          format: 'percent',
          label: 'cpu usage',
          logBase: 1,
          min: 0,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('avg(rate(node_cpu_seconds_total{mode="idle"}[2m]) * on(instance) group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s} * 100) by (mode)' % $._config, intervalFactor=10, legendFormat='% Idle') {
      step: 50,
    }),

    memoryFreeGraphPanel: commonGraph {
      title: 'Memory Free',
      description: 'Memory Usage in the Cluster',
      span: 4,
      yaxes: [
        {
          format: 'percent',
          label: 'memory usage',
          logBase: 1,
          min: 0,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('100 * (1 - ((sum(node_memory_MemTotal_bytes) - sum(node_memory_MemAvailable_bytes)) / sum(node_memory_MemTotal_bytes)))' % $._config, intervalFactor=10, legendFormat='% Free') {
      step: 50,
    }),

    memoryRequestsGauge: commonGauge {
      title: 'Memory Requests - Usage',
      description: 'Percentage of Allocatable Memory already requested by pods',
    }.addTarget(prometheus.target('sum(kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) / sum(kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s})' % $._config, instant=true) { step: 240 }),

    memoryRequestsDotPanel: statusDotPanel {
      title: 'Memory requested per node',
      description: 'Requested memory per Node',
    }.addTarget(prometheus.target('100 * (sum by (node) (kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) / sum by (node) (kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s}))' % $._config, instant=true)),

    ephemeralDiskUsageGauge: commonGauge {
      title: 'Ephemeral Disk - Usage',
      description: 'Percentage of ephemeral disk in use',
    }.addTarget(prometheus.target('1 - sum(node:node_filesystem_avail: - node:node_filesystem_usage:) / sum(node:node_filesystem_avail:)' % $._config, instant=true) { step: 240 }),

    ephemeralDiskUsageDotPanel: statusDotPanel {
      title: 'Ephemeral Disk usage per node',
      description: 'Percentage of ephemeral disk usage per node',
    }.addTarget(prometheus.target('100 * avg(node:node_filesystem_usage: * on(instance) group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s}) by (nodename)' % $._config, instant=true)),

    ephemeralDiskIOPanel: commonGraph {
      title: 'Ephemeral Disk IO',
      description: 'Ephemeral Disk IO',
      span: 4,
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        hideEmpty: false,
        hideZero: false,
        max: false,
        min: false,
        rightSide: false,
        show: true,
        total: false,
        values: false,
      },
      seriesOverrides: [
        {
          alias: 'read',
          yaxis: 1,
        },
        {
          alias: 'io time',
          yaxis: 2,
        },
      ],
      yaxes: [
        {
          format: 'bytes',
          logBase: 1,
          show: true,
        },
        {
          format: 's',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('sum(rate(node_disk_read_bytes_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='read') { step: 20 })
                          .addTarget(prometheus.target('sum(rate(node_disk_written_bytes_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='written') { step: 20 })
                          .addTarget(prometheus.target('sum(rate(node_disk_io_time_seconds_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='io time') { step: 20 }),


    numberOfNodes: commonSingleStat {
      title: 'Number of Nodes',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_info{node=~%(nodeSelectorRegex)s})' % $._config,
      )
    ),

    numberOfNodePools: commonSingleStat {
      title: 'Number of NodePools',
    }.addTarget(
      grafana.prometheus.target(
        'count (count by (label_cloud_google_com_gke_nodepool) (kube_node_labels{node=~%(nodeSelectorRegex)s}))' % $._config,
      )
    ),

    podsAvailableSlots: commonSingleStat {
      title: 'Pods Allocatables Slots',
    }.addTarget(
      grafana.prometheus.target(
        'sum (kube_node_status_allocatable_pods{node=~%(nodeSelectorRegex)s}) - sum(kube_pod_status_phase{phase="Running"})' % $._config,
      )
    ),

    nodesWithDiskPressure: commonSingleStat {
      title: 'Nodes Disk Pressures',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_status_condition{condition="DiskPressure", node=~%(nodeSelectorRegex)s, status="true"})' % $._config,
      )
    ),

    nodesNotReady: commonSingleStat {
      title: 'Nodes Not Ready',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_status_condition{condition="Ready", node=~%(nodeSelectorRegex)s, status="false"})' % $._config,
      )
    ),

    nodesUnavailable: commonSingleStat {
      title: 'Nodes Unavailable',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_spec_unschedulable{node=~%(nodeSelectorRegex)s})' % $._config,
      )
    ),

  },
}
