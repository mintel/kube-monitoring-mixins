local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';
local templates = import 'components/templates.libsonnet';
local omniWeb = import 'analytics.libsonnet';


// Dashboard settings
local dashboardTitle = 'Omni Web Dashboard Performance';
local dashboardDescription = "Provides performance breakdown of the Omni Web dashboards";
local dashboardFile = 'omni-web-dashboard-performance.json';

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
      .addTemplate(templates.dashboard_id)

      .addRow(
        row.new('Dashboards')
        .addPanels(omniWeb.dashboardRequest())

      )

      .addRow(
        row.new('Widgets')
        .addPanels(omniWeb.widgetRequest())
        .addPanels(omniWeb.dashboardRequestsRate())
      )

  },
}
