local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local tablePanel = grafana.tablePanel;
local singlestat = grafana.singlestat;


local commonGauge =
  singlestat.new(
    '',
    format='percentunit',
    datasource='Prometheus',
    span=2,
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

local statusDotPanel = {
  datasource: 'Prometheus',
  decimals: 2,
  defaultColor: 'rgb(0, 172, 64)',
  format: 'none',
  span: 2,
  mathColorValue: 'data[end]',
  mathDisplayValue: 'data[end]',
  mathScratchPad: 'data = size(data)[1] == 0 ? [NaN] : data',
  radius: '30px',
  thresholds: [
    {
      color: 'rgb(255, 142, 65)',
      value: '0.7',
    },
    {
      color: 'rgb(227, 228, 47)',
      value: '0.6',
    },
    {
      color: 'rgb(255, 0, 0)',
      value: '0.8',
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


{
  grafanaDashboards+:: {
    'capacity.json':
      local cpuCoresRequests = commonGauge {
        title: 'CPU Cores Requests - Usage',
        description: 'Percentage of Allocatable cpu cores already requested by pods',
      }.addTarget(prometheus.target('sum(kube_pod_container_resource_requests_cpu_cores{%(nodeSelector)s}) / sum(kube_node_status_allocatable_cpu_cores{%(nodeSelector)s})' % $._config, instant=true) { step: 240 });

      local cpuStatusDotPanel = statusDotPanel {
        title: 'CPU requested per node',
        description: 'Requested cpu per Node',
      }.addTarget(prometheus.target('sum by (node) (kube_pod_container_resource_requests_cpu_cores{%(nodeSelector)s}) / sum by (node) (kube_node_status_allocatable_cpu_cores{%(nodeSelector)s})' % $._config, instant=true));

      local memoryRequests = commonGauge {
        title: 'Memory Requests - Usage',
        description: 'Percentage of Allocatable Memory already requested by pods',
      }.addTarget(prometheus.target('sum(kube_pod_container_resource_requests_memory_bytes{%(nodeSelector)s}) / sum(kube_node_status_allocatable_memory_bytes{%(nodeSelector)s})' % $._config, instant=true) { step: 240 });

      local memoryStatusDotPanel = statusDotPanel {
        title: 'Memory requested per node',
        description: 'Requested memory per Node',
      }.addTarget(prometheus.target('sum by (node) (kube_pod_container_resource_requests_memory_bytes{%(nodeSelector)s}) / sum by (node) (kube_node_status_allocatable_memory_bytes{%(nodeSelector)s})' % $._config, instant=true));

      local ephemeralDiskUsage = commonGauge {
        title: 'Ephemeral Disk - Usage',
        description: 'Percentage of ephemeral disk in use',
      }.addTarget(prometheus.target('1 - sum(node:node_filesystem_avail: - node:node_filesystem_usage:) / sum(node:node_filesystem_avail:)' % $._config, instant=true) { step: 240 });

      local ephemeralStatusDotPanel = statusDotPanel {
        title: 'Ephemeral Disk usage per node',
        description: 'Percentage of ephemeral disk usage per node',
        thresholds: [
          {
            color: 'rgb(255, 142, 65)',
            value: '50',
          },
          {
            color: 'rgb(227, 228, 47)',
            value: '30',
          },
          {
            color: 'rgb(255, 0, 0)',
            value: '70',
          },
        ],
      }.addTarget(prometheus.target('100 * avg(node:node_filesystem_usage: * on(instance) group_left(nodename) node_uname_info{nodename=~"^gke.*"}) by (nodename)', instant=true));


      dashboard.new(
        '%(dashboardNamePrefix)sCapacity Planning' % $._config.grafanaK8s,
        time_from='now-5m',
        uid=($._config.grafanaDashboardIDs['capacity.json']),
        tags=($._config.grafanaK8s.dashboardTags) + ['capacity', 'resources'],
        description='A Dashboard to highlight current capacity usage and growth for your cluster'
      ).addRow(
        row.new('At a Glance')
        .addPanel(cpuCoresRequests)
        .addPanel(cpuStatusDotPanel)
        .addPanel(memoryRequests)
        .addPanel(memoryStatusDotPanel)
        .addPanel(ephemeralDiskUsage)
        .addPanel(ephemeralStatusDotPanel)
      ),
  },
}
