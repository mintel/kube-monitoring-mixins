local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';
local templates = import 'components/templates.libsonnet';
local redis = import 'components/panels/redis.libsonnet';
local django = import 'components/panels/django.libsonnet';
local celery = import 'components/panels/celery.libsonnet';
local webService = import 'components/panels/frontend-service.libsonnet';
local containerResources = import 'components/panels/container_resources.libsonnet';
local omniWeb = import 'omni-web-analytics.libsonnet';


// Dashboard settings
local dashboardTitle = 'Omni Web';
local dashboardDescription = "Provides an overview of the Omni Web Stack";
local dashboardFile = 'omni-web-overview.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);
local dashboardWorkloadLink = '/d/a164a7f0339f99e89cea5cb47e9be617';

local dashboardTags = ['omni'];
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
      .addTemplate(templates.namespace('omni', hide=true))
      .addTemplate(templates.app_service)

      .addRow(
        row.new('Overview', height=5)
        .addPanels(webService.overview())
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(django.requestResponsePanels())
      )
      .addRow(
        row.new('Resources')
        .addPanels(containerResources.containerResourcesPanel("$service"))
      )
      .addRow(
        row.new('Database', collapse=true)
        .addPanels(django.databaseOps())  
      )
      .addRow(
        row.new('Celery', collapse=true)
        .addPanels(celery.celeryPanels(serviceType='', startRow=1001))
      )
       .addRow(
        row.new('Redis', collapse=true)
        .addPanels(redis.clientPanels(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
        .addPanels(redis.workload(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
        .addPanels(redis.data(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
      )
  },
}
