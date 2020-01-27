local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import '_templates/utils/templates.libsonnet';

local panelsHeight = 300;

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
      .addTemplate(templates.namespace)
      .addTemplate(templates.app_service)
      .addRow(
        row.new('Overview')
        .addPanel($.panels.podsAvailableSlots)
        .addPanel($.panels.requestLatency{ height: panelsHeight })
      ),
  },
}
