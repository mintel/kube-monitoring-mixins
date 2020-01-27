local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local template = grafana.template;

local panelsHeight = 300;

(import '_templates/panels/django.libsonnet') +
{
  grafanaDashboards+:: {
    'portal-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Portal Overview' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['portal-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['overview', 'part-of/portal', 'component/portal-web'],
        description='A Dashboard providing an overview of the portal stack'
      )

      .addTemplate(
        grafana.template.datasource(
          'datasource',
          'prometheus',
          '',
        )
      ).addRow(
        row.new('Capacity at a Glance')
        .addPanel($.panels.cpuCoresRequestsGauge { height: panelsHeight })
        .addPanel($.panels.ephemeralDiskIOPanel { height: panelsHeight })
      ),
  },
}
