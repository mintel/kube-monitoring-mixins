local grafana = import 'grafonnet/grafana.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local graphPanel = grafana.graphPanel;
local grafana = import 'grafonnet/grafana.libsonnet';
local row = grafana.row;
local text = grafana.text;
local seriesOverrides = import 'components/series_overrides.libsonnet';
local singlestatPanel = grafana.singlestat;
local tablePanel = grafana.tablePanel;
local timepickerlib = import 'grafonnet/timepicker.libsonnet';
local templates = import 'components/templates.libsonnet';

{
  dashboard(
    title,
    tags,
    editable=false,
    time_from='now-6h',
    time_to='now',
    refresh='',
    timepicker=timepickerlib.new(),
    graphTooltip='shared_crosshair',
    hideControls=false,
    description=null,
    includeStandardEnvironmentAnnotations=true,
    includeEnvironmentTemplate=true,
  )::
    local dashboard = grafana.dashboard.new(
      title,
      style='light',
      schemaVersion=16,
      tags=tags,
      timezone='utc',
      graphTooltip=graphTooltip,
      editable=editable,
      refresh=refresh,
      hideControls=false,
      description=null,
    ).addTemplate(templates.ds); { },
}
