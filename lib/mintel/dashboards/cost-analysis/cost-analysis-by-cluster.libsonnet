local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local costAnalysis = import 'components/panels/cost-analysis.libsonnet';

// Dashboard settings
local dashboardTitle = 'Cost Analysis by Cluster';
local dashboardDescription = "Provides an analysis of costs by cluster";
local dashboardFile = 'cost-analysis-cluster-dashboard.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/%(uid)s/%(name)s' % {
  uid: dashboardUID,
  name: dashboardFile,
};
local dashboardTags = ['cost', 'utilisation', 'metrics'];

// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
           ($._config.mintel + {'dashboardTitle': dashboardTitle }),
        time_from='now-1h',
        editable='true',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.cost_discount('30'))
      .addTemplate(templates.cost_cpu('18.7'))
      .addTemplate(templates.cost_pcpu('5.6'))
      .addTemplate(templates.cost_storage_ssd('0.170'))
      .addTemplate(templates.cost_storage_standard('0.040'))
      .addTemplate(templates.cost_ram('3.57'))
      .addTemplate(templates.cost_pram('0.75'))

      .addRow(
        row.new()
        .addPanel(costAnalysis.cpuUtilisation(), gridPos={"h": 4,"w": 3,"x": 0,"y": 2})
        .addPanel(costAnalysis.cpuRequests(), gridPos={"h": 4,"w": 3,"x": 3,"y": 2})
        .addPanel(costAnalysis.cpuCost(), gridPos={"h": 4,"w": 4,"x": 6,"y": 2})
        .addPanel(costAnalysis.storageCost(), gridPos={"h": 4,"w": 4,"x": 10,"y": 2})
        .addPanel(costAnalysis.tableNode(), gridPos={"h": 8,"w": 10,"x": 14,"y": 2})
        .addPanel(costAnalysis.ramUtilisation(), gridPos={"h": 4,"w": 3,"x": 0,"y": 6})
        .addPanel(costAnalysis.ramRequests(), gridPos={"h": 4,"w": 3,"x": 3,"y": 6})
        .addPanel(costAnalysis.ramCost(), gridPos={"h": 4,"w": 4,"x": 6,"y": 6})
        .addPanel(costAnalysis.totalCost(), gridPos={"h": 4,"w": 4,"x": 10,"y": 6})
      )

      .addRow(
        row.new()
        .addPanel(costAnalysis.tableNamespace(), gridPos={"h": 11,"w": 14,"x": 0,"y": 10})
        .addPanel(costAnalysis.tablePVC(), gridPos={"h": 11,"w": 10,"x": 14,"y": 10})
      )

  },
}
