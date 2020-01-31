local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';
local thumbor = import '_templates/panels/thumbor.libsonnet';
local google = import '_templates/panels/google.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'image-sevice-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Portal' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['image-service-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['overview', 'image-service'],
        description='A Dashboard providing an overview of the image-service stack'
      )
      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('image-service'))
      .addTemplate(templates.app_service)
      .addTemplate(templates.celery_task_name)
      .addTemplate(templates.celery_task_state)
      .addRow(
        row.new('Overview', height=5)
        .addPanels(thumbor.overview(serviceType='', startRow=1))
      )
      .addRow(
        row.new('Google Buckets')
        .addPanels(google.bucketPanels(serviceType='', startRow=1001))
      )
      .addRow(
        row.new('Resources')
        .addPanels(thumbor.resourcePanels(serviceType='', startRow=1001))  
      )
  },
}
