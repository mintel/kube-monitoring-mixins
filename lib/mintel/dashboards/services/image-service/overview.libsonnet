local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local thumbor = import 'components/panels/thumbor.libsonnet';
local webService = import 'components/panels/frontend-service.libsonnet';
local containerResources = import 'components/panels/container_resources.libsonnet';

// Dashboard settings
local dashboardTitle = 'Image Service';
local dashboardDescription = "Provides an overview of the Image Service stack";
local dashboardFile = 'image-service-overview.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);
local dashboardWorkloadLink = '/d/a164a7f0339f99e89cea5cb47e9be617';

local dashboardTags = ['image-service'];
// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
           ($._config.mintel + {'dashboardTitle': dashboardTitle }),
        time_from='now-1h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addLink(link.dashboards(tags="",
        type="link",
        title="Workload",
        url=dashboardWorkloadLink,
        includeVars=true,
        keepTime=true,
        asDropdown=false,
        targetBlank=true))

      .addAnnotation(annotations.fluxRelease)
      .addAnnotation(annotations.fluxAutoRelease)

      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('image-service', hide=true))
      .addTemplate(templates.app_deployment)
      .addRow(
        row.new('Overview', height=5)
        .addPanels(webService.overview(serviceSelectorKey="job", serviceSelectorValue="$deployment"))
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(thumbor.requestResponsePanels())
      )
      .addRow(
        row.new('Resources')
        .addPanels(containerResources.containerResourcesPanel("$deployment"))
      )
      .addRow(
        row.new('Storage')
        .addPanels(thumbor.storagePanels())
      ),

  },
}
