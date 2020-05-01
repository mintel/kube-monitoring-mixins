local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local common = import 'components/panels/common.libsonnet';
local costAnalysis = import 'components/panels/cost-analysis.libsonnet';

// Dashboard settings
local dashboardTitle = 'Cost Analysis by Cluster';
local dashboardDescription = 'Provides an analysis of costs by cluster';
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
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-15m',
        editable='false',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.cost_cpu($._config.cost_cpu,hide=true))
      .addTemplate(templates.cost_pcpu($._config.cost_pcpu,hide=true))
      .addTemplate(templates.cost_ram($._config.cost_ram,hide=true))
      .addTemplate(templates.cost_pram($._config.cost_pram,hide=true))
      .addTemplate(templates.cost_storage_standard($._config.cost_storage_standard,hide=true))
      .addTemplate(templates.cost_storage_ssd($._config.cost_storage_ssd,hide=true))
      .addTemplate(templates.cost_discount($._config.cost_discount, hide=true))
      .addTemplate(templates.unaccounted_node_storage($._config.unaccounted_node_storage, hide=true))

      .addPanel(costAnalysis.overviewText(content=|||
                  This dashboard shows indicative monthly costing for the cluster, based on current requests for CPU, RAM and Storage.
                  Current Region Prices are for BELGIUM.
                |||),
                gridPos={
                  x: 0,
                  y: 0,
                  w: 24,
                  h: 2,
                })

      .addPanel(costAnalysis.cpuUtilisation(), gridPos={
        x: 0,
        y: 0,
        w: 3,
        h: 4,
      })
      .addPanel(costAnalysis.cpuRequests(), gridPos={
        x: 3,
        y: 0,
        w: 3,
        h: 4,
      })
      .addPanel(costAnalysis.cpuCost(), gridPos={
        x: 6,
        y: 0,
        w: 4,
        h: 4,
      })
      .addPanel(costAnalysis.storageCost($._config.hostMountpointSelector), gridPos={
        x: 10,
        y: 0,
        w: 4,
        h: 4,
      })

      .addPanel(costAnalysis.ramUtilisation(), gridPos={
        x: 0,
        y: 4,
        w: 3,
        h: 4,
      })
      .addPanel(costAnalysis.ramRequests(), gridPos={
        x: 3,
        y: 4,
        w: 3,
        h: 4,
      })
      .addPanel(costAnalysis.ramCost(), gridPos={
        x: 6,
        y: 4,
        w: 4,
        h: 4,
      })
      .addPanel(costAnalysis.totalCost($._config.hostMountpointSelector), gridPos={
        x: 10,
        y: 4,
        w: 4,
        h: 4,
      })

      .addPanel(costAnalysis.tableNode(), gridPos={
        x: 14,
        y: 0,
        w: 10,
        h: 8,
      })

      .addPanel(costAnalysis.tableNamespace(), gridPos={
        x: 0,
        y: 8,
        w: 11,
        h: 11,
      })
      .addPanel(costAnalysis.tablePVCCluster(), gridPos={
        x: 11,
        y: 8,
        w: 13,
        h: 11,
      }),


  },
}
