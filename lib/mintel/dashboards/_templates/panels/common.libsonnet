local grafana = import 'grafonnet/grafana.libsonnet';
local graphPanel = grafana.graphPanel;
local singlestatPanel = grafana.singlestat;
local tablePanel = grafana.tablePanel;
local row = grafana.row;
local text = grafana.text;

local promQuery = import '_templates/utils/prom_query.libsonnet';
local seriesOverrides = import '_templates/utils/series_overrides.libsonnet';
local timepickerlib = import 'grafonnet/timepicker.libsonnet';
local templates = import '_templates/utils/templates.libsonnet';

{
  singlestat(
    title='SingleStat',
    description='',
    query='',
    colors=[
      '#299c46',
      'rgba(237, 129, 40, 0.89)',
      '#d44a3a',
    ],
    legendFormat='',
    format='percentunit',
    gaugeMinValue=0,
    gaugeMaxValue=100,
    gaugeShow=false,
    instant=true,
    interval='1m',
    intervalFactor=3,
    postfix=null,
    thresholds='',
    yAxisLabel='',
    legend_show=true,
    linewidth=2,
    valueName='current',
  )::
    singlestatPanel.new(
      title,
      description=description,
      datasource='$ds',
      colors=colors,
      format=format,
      gaugeMaxValue=gaugeMaxValue,
      gaugeShow=gaugeShow,
      postfix=postfix,
      thresholds=thresholds,
      valueName=valueName,
    )
    .addTarget(promQuery.target(query, instant)),

  table(
    title='Table',
    description='',
    span=null,
    min_span=null,
    styles=[],
    columns=[],
  )::
    tablePanel.new(
      title,
      description=description,
      span=span,
      min_span=min_span,
      datasource='$ds',
      styles=[],
      columns=[],
    ),

  timeseries(
    title='Timeseries',
    description='',
    query='',
    legendFormat='',
    format='short',
    interval='1m',
    intervalFactor=3,
    yAxisLabel='',
    sort='decreasing',
    legend_show=true,
    legend_rightSide=false,
    linewidth=2,
    max=null,
  )::
    graphPanel.new(
      title,
      description=description,
      sort=sort,
      linewidth=linewidth,
      fill=0,
      datasource='$ds',
      decimals=0,
      legend_rightSide=legend_rightSide,
      legend_show=legend_show,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
      legend_hideEmpty=true,
    )
    .addTarget(promQuery.target(query, legendFormat=legendFormat, interval=interval, intervalFactor=intervalFactor))
    .resetYaxes()
    .addYaxis(
      format=format,
      min=0,
      max=max,
      label=yAxisLabel,
    )
    .addYaxis(
      format='short',
      max=1,
      min=0,
      show=false,
    ),

  queueLengthTimeseries(
    title='Timeseries',
    description='',
    query='',
    legendFormat='',
    format='short',
    interval='1m',
    intervalFactor=3,
    yAxisLabel='Queue Length',
    linewidth=2,
  )::
    graphPanel.new(
      title,
      description=description,
      sort='decreasing',
      linewidth=linewidth,
      fill=0,
      datasource='$ds',
      decimals=0,
      legend_show=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
      legend_hideEmpty=true,
    )
    .addTarget(promQuery.target(query, legendFormat=legendFormat, interval=interval, intervalFactor=intervalFactor))
    .resetYaxes()
    .addYaxis(
      format=format,
      min=0,
      label=yAxisLabel,
    )
    .addYaxis(
      format='short',
      max=1,
      min=0,
      show=false,
    ),

  latencyTimeseries(
    title='Latency',
    description='',
    query='',
    legendFormat='',
    format='s',
    yAxisLabel='Duration',
    interval='1m',
    intervalFactor=3,
    legend_show=true,
    logBase=1,
    decimals=2,
    linewidth=2,
    min=0,
  )::
    graphPanel.new(
      title,
      description=description,
      sort='decreasing',
      linewidth=linewidth,
      fill=0,
      datasource='$ds',
      decimals=decimals,
      legend_show=legend_show,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
      legend_hideEmpty=true,
    )
    .addTarget(promQuery.target(query, legendFormat=legendFormat, interval=interval, intervalFactor=intervalFactor))
    .resetYaxes()
    .addYaxis(
      format=format,
      min=min,
      label=yAxisLabel,
      logBase=logBase,
    )
    .addYaxis(
      format='short',
      max=1,
      min=0,
      show=false,
    ),

  slaTimeseries(
    title='SLA',
    description='',
    query='',
    legendFormat='',
    yAxisLabel='SLA',
    interval='1m',
    intervalFactor=3,
    points=false,
    pointradius=3,
  )::
    local formatConfig = {
      query: query,
    };
    graphPanel.new(
      title,
      description=description,
      sort='decreasing',
      linewidth=2,
      fill=0,
      datasource='$ds',
      decimals=2,
      legend_show=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
      legend_hideEmpty=true,
      points=points,
      pointradius=pointradius,
    )
    .addTarget(
      promQuery.target(
        |||
          clamp_min(clamp_max(%(query)s,1),0)
        ||| % formatConfig,
        legendFormat=legendFormat,
        interval=interval,
        intervalFactor=intervalFactor,
      )
    )
    .resetYaxes()
    .addYaxis(
      format='percentunit',
      max=1,
      label=yAxisLabel,
    )
    .addYaxis(
      format='short',
      max=1,
      min=0,
      show=false,
    ),

  networkTrafficGraph(
    title='Node Network Utilization',
    description='Network utilization',
    sendQuery,
    legendFormat='{{ fqdn }}',
    receiveQuery,
    intervalFactor=3,
    legend_show=true
  )::
    graphPanel.new(
      title,
      linewidth=1,
      fill=0,
      description=description,
      datasource='$ds',
      decimals=2,
      sort='decreasing',
      legend_show=legend_show,
      legend_values=false,
      legend_alignAsTable=false,
      legend_hideEmpty=true,
    )
    .addSeriesOverride(seriesOverrides.networkReceive)
    .addTarget(
      promQuery.target(
        sendQuery,
        legendFormat='send ' + legendFormat,
        intervalFactor=intervalFactor,
      )
    )
    .addTarget(
      promQuery.target(
        receiveQuery,
        legendFormat='receive ' + legendFormat,
        intervalFactor=intervalFactor,
      )
    )
    .resetYaxes()
    .addYaxis(
      format='Bps',
      label='Network utilization',
    )
    .addYaxis(
      format='short',
      max=1,
      min=0,
      show=false,
    ),
}
