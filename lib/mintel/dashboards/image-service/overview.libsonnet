local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';
local thumbor = import '_templates/panels/thumbor.libsonnet';
local haproxy = import '_templates/panels/haproxy.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'image-service-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Image Service' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['image-service-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['overview', 'image-service'],
        description='A Dashboard providing an overview of the image-service stack'
      )
      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('image-service'))
      .addTemplate(templates.app_deployment)
      .addRow(
        row.new('Overview', height=5)
        .addPanels(thumbor.overview(serviceType='', startRow=1))
        .addPanels(haproxy.overview(serviceType='', startRow=1))
      )
      .addRow(
        row.new('Resources')
        .addPanels(thumbor.resourcePanels(serviceType='', startRow=1001))
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(thumbor.requestResponsePanels(serviceType='', startRow=1001))
      )

      .addRow(
        row.new('Storage')
        .addPanels(thumbor.storagePanels(serviceType='', startRow=1001))
      ),

  },
}
