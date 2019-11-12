{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-overcommit',
        rules: [
          {
            // This rule count the number of nodes per gcp zone
            record: 'mintel:cluster:nodes_per_zone:count',
            expr: |||
              count by (zone) (label_replace(
                kube_node_info{%(kubeStateMetricsSelector)s}, "zone", "$1", "provider_id","gce://.*/(.*)/.*")
              )
            ||| % $._config,
          },
        ],
      },
    ],
  },
}
