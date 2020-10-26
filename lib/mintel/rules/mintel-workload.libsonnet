{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-workload.rules',
        rules: [
          {
            expr: |||
              sum(
                  node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate
                * on(namespace, pod)
                  group_left(workload, workload_type) mixin_pod_workload
              ) by (workload, namespace, workload_type)
            |||,
            record: 'mintel:workload:cpu_usage_seconds_total:rate5m',

          },
          // {
          //   expr: |||
          //     (
          //       mintel:workload:cpu_usage_seconds_total:rate5m
          //       -
          //       avg_over_time(mintel:workload:cpu_usage_seconds_total:rate5m)[1d]
          //     ) / stddev_over_time(mintel:workload:cpu_usage_seconds_total:rate5m)[1d]
          //   |||,
          //   record: 'mintel:workload:cpu_usage_seconds_total:rate5m:z_score'
          // },
        ],
      },
    ],
  },
}
