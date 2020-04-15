local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local haproxy = import 'components/panels/haproxy.libsonnet';
local thumbor = import 'components/panels/thumbor.libsonnet';
local webService = import 'components/panels/web-service.libsonnet';

// Dashboard settings
local dashboardTitle = 'Image Service Experimental';
local dashboardDescription = 'Provides an overview of the Image Service stack';
local dashboardFile = 'image-service-overview-experimental.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);
local dashboardWorkloadLink = '/d/a164a7f0339f99e89cea5cb47e9be617';

local dashboardTags = ['image-service', 'experimental'];
// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-1h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
      )

      .addLink(link.dashboards(tags='',
                               type='link',
                               title='Workload',
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
        .addPanels(webService.overview(serviceSelectorKey='job', serviceSelectorValue='$deployment'))
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(thumbor.requestResponsePanels())
        .addPanels([haproxy.latencyTimeseries('job', '$deployment', '$__interval', span=6) { description: 'Percentile Latency from HAProxy Ingress with AutoInterval' }])
      )
      .addRow(
        row.new('Resources')
        .addPanels(thumbor.resourcePanels())
      )
      .addRow(
        row.new('Storage')
        .addPanels(thumbor.storagePanels())
      ),

  },
}
