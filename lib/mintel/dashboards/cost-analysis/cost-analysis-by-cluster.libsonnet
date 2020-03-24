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
        row.new(height=5)
        .addPanel(costAnalysis.cpuUtilisation())
        .addPanel(costAnalysis.cpuRequests())
        .addPanel(costAnalysis.cpuCost())
        .addPanel(costAnalysis.storageCost())
      )

      .addRow(
        row.new(height=5)
        .addPanel(costAnalysis.ramUtilisation())
        .addPanel(costAnalysis.ramRequests())
        .addPanel(costAnalysis.ramCost())
        .addPanel(costAnalysis.totalCost())
      )

      .addRow(
        row.new(height=10)
        .addPanel(costAnalysis.tableNode())
        .addPanel(costAnalysis.tableNamespace())
        .addPanel(costAnalysis.tablePVC())
      )

  },
}
