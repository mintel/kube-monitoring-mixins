local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local costAnalysis = import 'components/panels/cost-analysis.libsonnet';

// Dashboard settings
local dashboardTitle = 'Cost Analysis by Namespace';
local dashboardDescription = "Provides an analysis of costs by namespace";
local dashboardFile = 'cost-analysis-namespace-dashboard.json';

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
      .addTemplate(templates.cost_cpu($._config.cost_cpu))
      .addTemplate(templates.cost_pcpu($._config.cost_pcpu))
      .addTemplate(templates.cost_ram($._config.cost_ram))
      .addTemplate(templates.cost_pram($._config.cost_pram))
      .addTemplate(templates.cost_storage_standard($._config.cost_storage_standard))
      .addTemplate(templates.cost_storage_ssd($._config.cost_storage_ssd))
      .addTemplate(templates.cost_discount($._config.cost_discount))
      .addTemplate(templates.cost_namespace('monitoring'))


      .addPanel(costAnalysis.tablePodCost(), gridPos={
                                              "x": 0,
                                              "y": 0,
                                              "w": 16,
                                              "h": 9})

      .addPanel(costAnalysis.tablePVCNamespace(), gridPos={
                                              "x": 16,
                                              "y": 0,
                                              "w": 8,
                                              "h": 9})

      .addPanel(costAnalysis.graphOverallCPU(), gridPos={
                                              "x": 0,
                                              "y": 9,
                                              "w": 12,
                                              "h": 6})

      .addPanel(costAnalysis.graphOverallRAM(), gridPos={
                                              "x": 12,
                                              "y": 9,
                                              "w": 12,
                                              "h": 6})

  },
}
