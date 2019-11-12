{
  prometheusRules+:: {
    groups+: [
      {
        name: 'blackbox',
        rules: [{
          expr: 'topk(1, count by (target) (up{job="blackbox"}))',
          record: 'blackbox_node_count',
        }],
      },
    ],
  },
}
