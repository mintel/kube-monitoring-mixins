local grafana = import 'grafonnet/grafana.libsonnet';
local graphPanel = grafana.graphPanel;
local singlestatPanel = grafana.singlestat;
local tablePanel = grafana.tablePanel;
local row = grafana.row;
local text = grafana.text;
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';
local timepickerlib = import 'grafonnet/timepicker.libsonnet';
local templates = import 'components/templates.libsonnet';
local statusdotsPanel = import 'statusdots_panel.libsonnet';

{
  text(
    title='Table',
    mode='markdown',
    content='',
    datasource=null,
    transparent=null,
  )::
    text.new(
      title=title,
      mode=mode,
      content=content,
      datasource=datasource,
      transparent=transparent,
    ),

  statusdots(
    title='StatusDotPanel',
    description='',
    query='',
    height=200,
    span=null,
    instant=true,
  )::
    statusdotsPanel.new(
      title,
      description=description,
      height=height,
      span=span
    )
    .addTarget(promQuery.target(query, instant=instant)),

  singlestat(
    title='SingleStat',
    description='',
    query='',
    colors=[
      '#299c46',
      'rgba(237, 129, 40, 0.89)',
      '#d44a3a',
    ],
    datasource='$ds',
    decimals=null,
    legendFormat='',
    format='none',
    gaugeMinValue=0,
    gaugeMaxValue=100,
    gaugeShow=false,
    sparklineFull=true,
    sparklineShow=true,
    instant=false,
    interval='1m',
    intervalFactor=2,
    postfix=null,
    thresholds='',
    yAxisLabel='',
    legend_show=true,
    linewidth=2,
    valueName='current',
    span=null,
    height=200,
    colorBackground=false,
    colorValue=false,
    valueMaps=[],
  )::
    singlestatPanel.new(
      title,
      description=description,
      datasource=datasource,
      decimals=decimals,
      colors=colors,
      format=format,
      gaugeMaxValue=gaugeMaxValue,
      gaugeShow=gaugeShow,
      postfix=postfix,
      thresholds=thresholds,
      valueName=valueName,
      span=span,
      height=height,
      sparklineFull=sparklineFull,
      sparklineShow=sparklineShow,
      colorBackground=colorBackground,
      colorValue=colorValue,
      valueMaps=valueMaps,
    )
    .addTarget(promQuery.target(query, instant=instant)),

  gauge(
    title='Gauge',
    description='',
    query='',
    colors=[
      'rgba(50, 172, 45, 0.97)',
      'rgba(237, 129, 40, 0.89)',
      'rgba(245, 54, 54, 0.9)',
    ],
    colorValue=false,
    decimals=null,
    thresholds='.8, .9',
    format='percentunit',
    gaugeMinValue=0,
    gaugeMaxValue=1,
    instant=true,
    height=200,
    valueFontSize='100%',
    transparent=true,
    interval='1m',
    intervalFactor=2,
    postfix=null,
    valueName='avg',
    span=null,
  )::
    singlestatPanel.new(
      title=title,
      description=description,
      colors=colors,
      colorValue=colorValue,
      decimals=decimals,
      thresholds=thresholds,
      format=format,
      gaugeShow=true,
      gaugeMinValue=gaugeMinValue,
      gaugeMaxValue=gaugeMaxValue,
      height=height,
      valueFontSize=valueFontSize,
      valueName=valueName,
      transparent=transparent,
      interval=interval,
      postfix=postfix,
      span=span,
    )
    .addTarget(promQuery.target(query, instant=instant, interval=interval, intervalFactor=intervalFactor)),

  table(
    title='Table',
    description='',
    span=null,
    min_span=null,
    styles=[],
    columns=[],
    query='',
    format='table',
    height=null,
    instant='true',
    legendFormat='',
    interval='',
    intervalFactor='',
  )::
    tablePanel.new(
      title,
      description=description,
      span=span,
      height=height,
      min_span=min_span,
      datasource='$ds',
      styles=styles,
      columns=columns,
    )
    .addTarget(promQuery.target(query, format=format, instant=instant, legendFormat=legendFormat, interval=interval, intervalFactor=intervalFactor)),

  timeseries(
    title='Timeseries',
    description='',
    decimals=2,
    query='',
    legendFormat='',
    fill=0,
    format='short',
    interval='1m',
    intervalFactor=2,
    yAxisLabel='',
    sort='decreasing',
    legend_show=true,
    legend_rightSide=false,
    linewidth=2,
    stack=false,
    min=0,
    max=null,
    height=200,
    nullPointMode='null',
    span=null,
    thresholds=[],
  )::
    graphPanel.new(
      title,
      description=description,
      sort=sort,
      stack=stack,
      linewidth=linewidth,
      fill=fill,
      datasource='$ds',
      decimals=decimals,
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
      height=height,
      nullPointMode=nullPointMode,
      span=span,
      thresholds=thresholds
    )
    .addTarget(promQuery.target(query, legendFormat=legendFormat, interval=interval, intervalFactor=intervalFactor))
    .resetYaxes()
    .addYaxis(
      format=format,
      min=min,
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
    intervalFactor=2,
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
    format='ms',
    yAxisLabel='Duration',
    interval='1m',
    intervalFactor=2,
    legend_show=true,
    logBase=1,
    decimals=2,
    linewidth=2,
    min=0,
    height=200,
    span=null,
    nullPointMode='connected'
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
      height=height,
      span=span,
      nullPointMode=nullPointMode
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
    intervalFactor=2,
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
    intervalFactor=2,
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
