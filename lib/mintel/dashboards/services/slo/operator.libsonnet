local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local templates = import 'components/templates.libsonnet';

local slo = import 'components/panels/slo-operator.libsonnet';

// Dashboard settings
local dashboardTitle = 'SLO Operator';
local dashboardDescription = 'Provides an overview of slo';
local dashboardFile = 'slo-operator.json';

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
        time_from='now-1h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('', ''))
      .addTemplate(templates.slo_operator_services())
      .addTemplate(templates.slo_operator_slo())
      .addTemplate(templates.slo_availability_span(current='1h'))

      .addRow(
        row.new('SLI/SLO for service ${slo_service} on ${slo}', repeat='slo', height=300)
        .addPanel(slo.serviceLevelAvailabilityOverTime(namespace='$namespace', sloService='$slo_service', slo='$slo', availabilitySpan='$slo_availability_span'))
        .addPanel(slo.serviceLevelAvailabilityBreachesTimeSeries(namespace='$namespace', sloService='$slo_service', slo='$slo', interval='15s'))
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
