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
        time_from='now/w',
        time_to='now',
        hideControls=true,
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.slo_operator_slo_namespaces())
      .addTemplate(templates.slo_operator_services())
      .addTemplate(templates.slo_operator_slo())
      .addTemplate(templates.slo_availability_span(current='7d'))

      .addRow(
        row.new('SLI/SLO for service ${slo_service} on ${slo}', repeat='slo', height=300)
        .addPanel(slo.serviceLevelAvailabilityOverTime(namespace='$slo_namespace', sloService='$slo_service', slo='$slo', availabilitySpan='$slo_availability_span'))
        .addPanel(slo.serviceLevelAvailabilityBreachesTimeSeries(namespace='$slo_namespace', sloService='$slo_service', slo='$slo', interval='30s'))
        .addPanel(slo.serviceLevelBurndownStat(namespace='$slo_namespace', sloService='$slo_service', projection='week', slo='$slo'))
      ),
  },
}
