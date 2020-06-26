local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local templates = import 'components/templates.libsonnet';

local slislo = import 'components/panels/sli_slo.libsonnet';

// Dashboard settings
local dashboardTitle = 'SLO Overview';
local dashboardDescription = 'Provides an overview of slo for a given service';
local dashboardFile = 'slo-overview.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);

local dashboardTags = ['slo'];
// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-1d',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.slo_enabled_backend_services())
      .addTemplate(templates.slo_availability_span())

      .addRow(
        row.new('Overview', height=3)
        .addPanel(slislo.serviceLevelAvailabilityOverTime(backendServiceSelector='$slo_backend_service', availabilitySpan='$slo_availability_span'))
      ),
    //.addRow(
    //  row.new('Request / Response')
    //  .addPanels(django.requestResponsePanels())
    //)
    //.addRow(
    //  row.new('Resources')
    //  .addPanels(containerResources.containerResourcesPanel('$service'))
    //)
    //.addRow(
    //  row.new('Database', collapse=true)
    //  .addPanels(django.databaseOps())
    //)
    //.addRow(
    //  row.new('Celery', collapse=true)
    //  .addPanels(celery.celeryPanels(serviceType='', startRow=1001))
    //)
    //.addRow(
    //  row.new('Redis', collapse=true)
    //  .addPanels(redis.clientPanels(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
    //  .addPanels(redis.workload(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
    //  .addPanels(redis.data(serviceSelectorKey='service', serviceSelectorValue='$service.*', startRow=1002))
    //),
  },
}
