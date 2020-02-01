local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local thumbor = import 'components/panels/thumbor.libsonnet';
local haproxy = import 'components/panels/haproxy.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'image-service-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Image Service' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['image-service-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['image-service'],
        description='A Dashboard providing an overview of the image-service stack'
      )

      .addLink(link.dashboards(tags="",
        type="link",
        title="Workload",
        url="d/a164a7f0339f99e89cea5cb47e9be617/",
        includeVars=true,
        keepTime=true,
        asDropdown=false,
        targetBlank=true))
      .addAnnotation(annotations.fluxRelease)
      .addAnnotation(annotations.fluxAutoRelease)

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
