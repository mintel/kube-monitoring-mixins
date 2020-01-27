local grafana = import 'grafonnet/grafana.libsonnet';
local promQuery = import 'prom_query.libsonnet';
local graphPanel = grafana.graphPanel;
local grafana = import 'grafonnet/grafana.libsonnet';
local heatmapPanel = grafana.heatmapPanel;
local row = grafana.row;
local seriesOverrides = import 'series_overrides.libsonnet';
local singlestatPanel = grafana.singlestat;
local tablePanel = grafana.tablePanel;
local timepickerlib = import 'grafonnet/timepicker.libsonnet';
local templates = import 'templates.libsonnet';

{
  dashboard(
    title,
    tags,
    editable=false,
    time_from='now-3h',
    time_to='now',
    refresh='',
    timepicker=timepickerlib.new(),
    graphTooltip='shared_crosshair',
    hideControls=false,
    description=null,
    includeStandardEnvironmentAnnotations=false,
    includeEnvironmentTemplate=false,
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
    ).addTemplate(templates.ds);  // All dashboards include the `ds` variable
}
