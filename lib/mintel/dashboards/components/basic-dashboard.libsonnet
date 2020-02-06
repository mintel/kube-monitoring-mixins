local grafana = import 'grafonnet/grafana.libsonnet';
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
  )::
    local dashboard = grafana.dashboard.new(
      title,
      style='dark',
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
