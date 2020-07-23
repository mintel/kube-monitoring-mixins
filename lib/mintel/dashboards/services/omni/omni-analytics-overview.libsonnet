local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';
local templates = import 'components/templates.libsonnet';
local containerResources = import 'components/panels/container_resources.libsonnet';
local backendService = import 'components/panels/backend-service.libsonnet';
local omniAnalytics = import 'omni-web-analytics.libsonnet';


// Dashboard settings
local dashboardTitle = 'Omni Analytics';
local dashboardDescription = "Provides an overview of the Omni Analytics Stack";
local dashboardFile = 'omni-analytics-overview.json';

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
      .addTemplate(grafana.template.new(
        'analytics_type',
        'Prometheus',
        'label_values(http_request_duration_seconds_count{namespace="omni"}, analytics_type)',
        label='Analytics Type',
        refresh='time',
        allValues='.*',
        current='',
        includeAll=true,
        multi=true,
      ))
      .addRow(
        row.new('Overview', height=5)
        .addPanels(backendService.overview())
      )
      .addRow(
        row.new('API Service', height=5)
        .addPanels(omniAnalytics.apiServiceLatency())
      )
      .addRow(
        row.new('ES Responses', height=5)
        .addPanels(omniAnalytics.elasticSearchResponses())
      )
      .addRow(
        row.new('Resources')
        .addPanels(containerResources.containerResourcesPanel("$service"))
      )

  },
}
