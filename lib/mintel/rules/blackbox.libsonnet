{
  prometheusRules+:: {
    groups+: [
      {
        name: 'blackbox.rules',
        rules: [
          {
            expr: 'count by (target,job,app_mintel_com_owner) (up{job="blackbox"})',
            record: 'blackbox_node_count',
          },
        ],
      },
    ],
  },
}
