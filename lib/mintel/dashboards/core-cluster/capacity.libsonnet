local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local capacity = import 'components/panels/capacity.libsonnet';


// Will probably drop these soon as they aren't used (but may prove useful later)
local startRowNodesOverview=1000;
local startRowCapacityOverview=1001;

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
        row.new('Nodes Overview')
        .addPanel(capacity.numberOfNodes($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.numberOfNodePools($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.podsAvailableSlots($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesWithDiskPressure($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesNotReady($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesUnavailable($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
      )
      .addRow(
        row.new('Capacity Overview')
        .addPanel(capacity.cpuCoresRequests($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.cpuCoresRequestsStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.memoryRequests($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.memoryRequestsStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.ephemeralDiskUsageGauge($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.ephemeralDiskUsageStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))

        .addPanel(capacity.cpuIdle($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
        .addPanel(capacity.memoryFree($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
        .addPanel(capacity.ephemeralDiskIO($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
      )  
  },
}