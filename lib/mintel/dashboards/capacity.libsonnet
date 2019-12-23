local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local tablePanel = grafana.tablePanel;
local singlestat = grafana.singlestat;

local panelsHeight = 300;

{
  grafanaDashboards+:: {
    'cluster-capacity.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Capacity / Planning' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['capacity.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['capacity', 'resources', 'kubernetes'],
        description='A Dashboard to highlight current capacity usage and growth for your cluster'
      )

      .addTemplate(
        grafana.template.datasource(
          'datasource',
          'prometheus',
          '',
        )

      ).addRow(
        grafana.row.new('Nodes')
        .addPanel($.widgets.numberOfNodes)
        .addPanel($.widgets.numberOfNodePools)
        .addPanel($.widgets.podsAvailableSlots)
        .addPanel($.widgets.nodesWithDiskPressure)
        .addPanel($.widgets.nodesNotReady)
        .addPanel($.widgets.nodesUnavailable)
      ).addRow(
        row.new('Capacity at a Glance')
        .addPanel($.widgets.cpuCoresRequestsGauge { height: panelsHeight })
        .addPanel($.widgets.cpuCoresRequestsDotPanel { height: panelsHeight })
        .addPanel($.widgets.memoryRequestsGauge { height: panelsHeight })
        .addPanel($.widgets.memoryRequestsDotPanel { height: panelsHeight })
        .addPanel($.widgets.ephemeralDiskUsageGauge { height: panelsHeight })
        .addPanel($.widgets.ephemeralDiskUsageDotPanel { height: panelsHeight })
        .addPanel($.widgets.cpuIdleGraphPanel { height: panelsHeight })
        .addPanel($.widgets.memoryFreeGraphPanel { height: panelsHeight })
        .addPanel($.widgets.ephemeralDiskIOPanel { height: panelsHeight })
      ),
  },
}
