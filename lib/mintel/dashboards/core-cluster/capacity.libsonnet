local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local capacity = import 'components/panels/capacity.libsonnet';

// Will probably drop these soon as they aren't used (but may prove useful later)
local startRowNodesOverview=1000;
local startRowCapacityOverview=1001;

// Dashboard settings
local dashboardTitle = 'Capacity Planning';
local dashboardDescription = 'A Dashboard to highlight current capacity usage and growth for your cluster';
local dashboardFile = 'cluster-capacity-planning.json';
local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/%(uid)s/%(name)s' % {
  uid: dashboardUID,
  name: dashboardFile
};
local dashboardTags = ['capacity', 'resources'];

// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
           ($._config.mintel + {'dashboardTitle': dashboardTitle }),
        time_from='now-1h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)

      .addRow(
        row.new('Nodes Overview')
        .addPanel(capacity.numberOfNodesStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.numberOfNodePoolsStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.podsAvailableSlotsStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesWithDiskPressureStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesNotReadyStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
        .addPanel(capacity.nodesUnavailableStat($._config.nodeSelectorRegex, startRow=startRowNodesOverview))
      )

      .addRow(
        row.new('Capacity Overview')
        .addPanel(capacity.cpuCoresRequestsGauge($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.cpuCoresRequestsStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.memoryRequestsGauge($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.memoryRequestsStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.ephemeralDiskUsageGauge($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))
        .addPanel(capacity.ephemeralDiskUsageStatusDots($._config.nodeSelectorRegex, startRow=startRowCapacityOverview))

        .addPanel(capacity.cpuIdleGraph($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
        .addPanel(capacity.memoryFreeGraph($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
        .addPanel(capacity.ephemeralDiskIOGraph($._config.nodeSelectorRegex, startRow=startRowCapacityOverview, span=4))
      )
  },
}
