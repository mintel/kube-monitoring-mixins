local grafana = import 'grafonnet/grafana.libsonnet';
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;

{
  gauge::
    singlestat.new(
      '',
      format='percentunit',
      datasource='$datasource',
      span=2,
      height=150,
      valueName='avg',
      valueFontSize='110%',
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      thresholds='.8, .9',
      transparent=true,
      gaugeShow=true,
      gaugeMinValue=0,
      gaugeMaxValue=1,
    ),

  singlestat::
    singlestat.new(
      '',
      datasource='$datasource',
      height=100,
      sparklineShow=true,
      span=2,
    ),

  graphPanel::
    graphPanel.new(
      '',
      datasource='$datasource',
      span=2,
      legend_show=false,
      linewidth=2,
      height=150,
    ),

  statusDotPanel:: {
    datasource: '$datasource',
    decimals: 2,
    defaultColor: 'rgb(0, 172, 64)',
    format: 'none',
    height: 150,
    span: 2,
    mathColorValue: 'data[end]',
    mathDisplayValue: 'data[end]',
    mathScratchPad: 'data = size(data)[1] == 0 ? [NaN] : data',
    radius: '30px',
    thresholds: [
      {
        color: 'rgb(255, 142, 65)',
        value: '70',
      },
      {
        color: 'rgb(227, 228, 47)',
        value: '40',
      },
      {
        color: 'rgb(255, 0, 0)',
        value: '85',
      },
    ],
    type: 'btplc-status-dot-panel',
    targets: [],
    _nextTarget:: 0,
    addTarget(target):: self {
      local nextTarget = super._nextTarget,
      _nextTarget: nextTarget + 1,
      targets+: [target { refId: std.char(std.codepoint('A') + nextTarget) }],
    },
  },
}
