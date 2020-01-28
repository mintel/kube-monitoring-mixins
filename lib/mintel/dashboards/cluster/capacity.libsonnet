local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';
local common = import '_templates/panels/common.libsonnet';
local capacity = import '_templates/panels/capacity.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'cluster-capacity.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Portal' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['cluster-capacity.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['capacity', 'resources', 'kubernetes'],
        description='A Dashboard to highlight current capacity usage and growth for your cluster'
      )
      .addTemplate(templates.ds)
      .addRow(
        row.new('Nodes', height=5)
        .addPanels(django.overview(serviceType='', startRow=1))
        .addPanel(capacity.numberOfNodes)
        .addPanel(capacity.numberOfNodePools)
        .addPanel(capacity.podsAvailableSlots)
        .addPanel(capacity.nodesWithDiskPressure)
        .addPanel(capacity.nodesNotReady)
        .addPanel(capacity.nodesUnavailable)

      )
      .addRow(
        row.new('Capacity')
        .addPanels(django.requestResponsePanels(serviceType='', startRow=1001))
        .addPanel(capacity.cpuCoresRequestsGauge)
        .addPanel(capacity.cpuCoresRequestsDotPanel)
        .addPanel(capacity.memoryRequestsGauge)
        .addPanel(capacity.memoryRequestsDotPanel)
        .addPanel(capacity.ephemeralDiskUsageGauge)
        .addPanel(capacity.ephemeralDiskUsageDotPanel)
        .addPanel(capacity.cpuIdleGraphPanel)
        .addPanel(capacity.memoryFreeGraphPanel)
        .addPanel(capacity.ephemeralDiskIOPanel)
       
  },
}