local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local health = import 'components/panels/health.libsonnet';

// Dashboard settings
local dashboardTitle = 'Cluster Health';
local dashboardDescription = 'A Dashboard to show general kubernetes cluster health';
local dashboardFile = 'cluster-health.json';
local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/%(uid)s/%(name)s' % {
  uid: dashboardUID,
  name: dashboardFile
};
local dashboardTags = ['health'];

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
        row.new('General Status')
        .addPanel(health.alertsFiring())
        .addPanel(health.alertsPending())
        .addPanel(health.targetDownFiring())
        .addPanel(health.nodeBadConditions())
      )

      .addRow(
        row.new('Pod Status')
        .addPanel(health.crashloopingPods())
        .addPanel(health.statefulReplicaMismatch())
        .addPanel(health.deploymentReplicaMismatch())
        .addPanel(health.daemonsetRolloutStuck())
        .addPanel(health.daemonsetNotScheduled())
        .addPanel(health.oomKilledPods())
      )

      .addRow(
        row.new('Node Status')
        .addPanel(health.nodeNotReady())
        .addPanel(health.nodeDiskPressure())
        .addPanel(health.nodeMemoryPressure())
        .addPanel(health.nodesUnschedulable())
        .addPanel(health.nodesLowCpuCount())
        .addPanel(health.nodesLowMemoryCount())
      )
  },
}