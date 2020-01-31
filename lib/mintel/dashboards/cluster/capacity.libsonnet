local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';
local common = import '_templates/panels/common.libsonnet';
local capacity = import '_templates/panels/capacity.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'cluster-capacity.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Cluster Capacity' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['cluster-capacity.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['capacity', 'resources', 'kubernetes'],
        description='A Dashboard to highlight current capacity usage and growth for your cluster'
      )
      .addTemplate(templates.ds)
      .addRow(
        row.new('Nodes Overview', height=5)
        .addPanel(capacity.numberOfNodes($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.numberOfNodePools($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.podsAvailableSlots($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.nodesWithDiskPressure($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.nodesNotReady($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.nodesUnavailable($._config.nodeSelectorRegex, startRow=1001))
      )
      .addRow(
        row.new('Capacity Overview')
        .addPanel(capacity.cpuCoresRequests($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.cpuCoresRequestsStatusDots($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.cpuIdle($._config.nodeSelectorRegex, startRow=1001))

        .addPanel(capacity.memoryFree($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.memoryRequests($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.memoryRequestsStatusDots($._config.nodeSelectorRegex, startRow=1001))

        .addPanel(capacity.ephemeralDiskUsageGauge($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.ephemeralDiskIO($._config.nodeSelectorRegex, startRow=1001))
        .addPanel(capacity.ephemeralDiskUsageStatusDots($._config.nodeSelectorRegex, startRow=1001))

      )
        // .addPanel(capacity.cpuCoresRequestsDotPanel)
        // .addPanel(capacity.memoryRequestsDotPanel)
        // .addPanel(capacity.ephemeralDiskUsageDotPanel)       
  },
}