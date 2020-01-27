local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local templates = import '_templates/utils/templates.libsonnet';
local panelsHeight = 300;

(import '_templates/panels/capacity.libsonnet') +
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

      .addTemplate(templates.ds)
      .addRow(
        grafana.row.new('Nodes')
        .addPanel($.panels.numberOfNodes)
        .addPanel($.panels.numberOfNodePools)
        .addPanel($.panels.podsAvailableSlots)
        .addPanel($.panels.nodesWithDiskPressure)
        .addPanel($.panels.nodesNotReady)
        .addPanel($.panels.nodesUnavailable)
      ).addRow(
        row.new('Capacity at a Glance')
        .addPanel($.panels.cpuCoresRequestsGauge { height: panelsHeight })
        .addPanel($.panels.cpuCoresRequestsDotPanel { height: panelsHeight })
        .addPanel($.panels.memoryRequestsGauge { height: panelsHeight })
        .addPanel($.panels.memoryRequestsDotPanel { height: panelsHeight })
        .addPanel($.panels.ephemeralDiskUsageGauge { height: panelsHeight })
        .addPanel($.panels.ephemeralDiskUsageDotPanel { height: panelsHeight })
        .addPanel($.panels.cpuIdleGraphPanel { height: panelsHeight })
        .addPanel($.panels.memoryFreeGraphPanel { height: panelsHeight })
        .addPanel($.panels.ephemeralDiskIOPanel { height: panelsHeight })
      ),
  },
}