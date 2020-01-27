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
        .addPanel($.panels.djangoRequestLatency{ height: panelsHeight })
        .addPanel($.panels.djangoResponseStatus{ height: panelsHeight })

      ),
  },
}
