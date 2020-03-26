local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local costAnalysis = import 'components/panels/cost-analysis.libsonnet';

// Dashboard settings
local dashboardTitle = 'Cost Analysis by Pod';
local dashboardDescription = 'Provides an analysis of costs by pod';
local dashboardFile = 'cost-analysis-pod-dashboard.json';

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
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-15m',
        editable='true',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.cost_cpu($._config.cost_cpu,hide=true))
      .addTemplate(templates.cost_pcpu($._config.cost_pcpu,hide=true))
      .addTemplate(templates.cost_ram($._config.cost_ram,hide=true))
      .addTemplate(templates.cost_pram($._config.cost_pram,hide=true))
      .addTemplate(templates.cost_storage_standard($._config.cost_storage_standard,hide=true))
      .addTemplate(templates.cost_storage_ssd($._config.cost_storage_ssd,hide=true))
      .addTemplate(templates.cost_discount($._config.cost_discount, hide=true))
      .addTemplate(templates.cost_namespace($._config.namespace))
      .addTemplate(templates.cost_pod(''))


      .addPanel(costAnalysis.tableContainerCost(), gridPos={
        x: 0,
        y: 0,
        w: 24,
        h: 6,
      })

      .addPanel(costAnalysis.graphPodCPU(), gridPos={
        x: 0,
        y: 9,
        w: 12,
        h: 8,
      })

      .addPanel(costAnalysis.graphPodRAM(), gridPos={
        x: 12,
        y: 9,
        w: 12,
        h: 8,
      })

      .addPanel(costAnalysis.graphPodNetworkIO(), gridPos={
        x: 0,
        y: 15,
        w: 12,
        h: 8,
      })

      .addPanel(costAnalysis.graphPodDiskIO(), gridPos={
        x: 12,
        y: 15,
        w: 12,
        h: 8,
      }),

  },
}
