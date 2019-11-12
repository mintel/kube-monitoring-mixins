{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-overcommit.rules.rules',
        rules: [{
          expr: 'count by (zone) (label_replace(kube_node_info, "zone", "$1", "provider_id", "gce://.*/(.*)/.*"))',
          record: 'mintel:cluster:nodes_per_zone:count',
        }
                {
          expr: 'count(mintel:cluster:nodes_per_zone:count)',
          record: 'mintel:cluster:zones:count',
        }],
      },
    ],
  },
}
