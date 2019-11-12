{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-disk',
        rules: [
          {
            record: 'mintel:pvc:inodes_free:percentage',
            expr: |||
              (kubelet_volume_stats_inodes_free{%(kubeletSelector)s} / kubelet_volume_stats_inodes{%(kubeletSelector)s}) * 100
            ||| % $._config,
          },
        ],
      },
    ],
  },
}
