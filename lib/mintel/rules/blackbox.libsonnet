{
  prometheusRules+:: {
    groups+: [
      {
        name: 'blackbox.rules',
        rules: [
          {
            expr: 'count by (target,job) (up{job="blackbox"})',
            record: 'blackbox_node_count',
          },
        ],
      },
    ],
  },
}
