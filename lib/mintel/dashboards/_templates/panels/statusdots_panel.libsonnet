{
  /**
   * Returns a new statutsdots panel that can be added in a row.
   *
   * See https://github.com/BT-OpenSource/bt-grafana-status-dot
   *
   * @param title The title of the statutsdots panel.
   * @param description The description of the statusdots panel.
   *
   */
  new(
    title,
    description,
    query='',
  ):: {
    title: title,
    [if description != null then 'description']: description,
    datasource: '$ds',
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
    addTargets(targets):: std.foldl(function(p, t) p.addTarget(t), targets, self),
  },
}
