local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';

local panelsHeight = 200;

(import '_templates/panels/django.libsonnet') +
{
  grafanaDashboards+:: {
    'portal-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Portal' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['portal-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['overview', 'part-of/portal', 'component/portal-web'],
        description='A Dashboard providing an overview of the portal stack'
      )
      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('portal'))
      .addTemplate(templates.app_service)
      .addRow(
        row.new('Overview')
        .addPanel($.panels.commonPodsAvailableSlots{ height: panelsHeight })
        .addPanel($.panels.djangoResponseStat('2xx', '2.+') { height: panelsHeight })
        .addPanel($.panels.djangoResponseStat('3xx', '3.+') { height: panelsHeight })
        .addPanel($.panels.djangoResponseStat('4xx', '4.+') { height: panelsHeight })
        .addPanel($.panels.djangoResponseStat('5xx', '5.+') { height: panelsHeight })
      )
      .addRow(
        row.new('Request / Response')
        .addPanel($.panels.djangoRequestLatency{ height: panelsHeight })
        .addPanel($.panels.djangoResponseStatus{ height: panelsHeight })
        .addPanel($.panels.djangoRequestsByMethodView{ height: panelsHeight })
      )
      .addRow(
        row.new('Resources')
        .addPanel($.panels.commonContainerMemoryUsage{ height: panelsHeight },)  
        .addPanel($.panels.commonContainerCPUUsage{ height: panelsHeight },)  
      )
      .addRow(
        row.new('Database')
        .addPanel($.panels.djangoDatabaseOps{ height: panelsHeight },)  
      )

  },
}
