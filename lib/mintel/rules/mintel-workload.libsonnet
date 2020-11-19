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
                         group_left(workload, workload_type) namespace_workload_pod:kube_pod_owner:relabel
                     ) by (workload, namespace, workload_type)
                   |||,
                   record: 'mintel:workload:cpu_usage_seconds_total:rate5m',

                 },
               ]
               + [
                 {
                   expr: |||
                     abs(
                       (
                         mintel:workload:cpu_usage_seconds_total:rate5m
                         -
                         avg_over_time(mintel:workload:cpu_usage_seconds_total:rate5m[%(avg_over_time_period)s])
                       ) / stddev_over_time(mintel:workload:cpu_usage_seconds_total:rate5m[%(stddev_over_time_period)s])
                     )
                   ||| % { avg_over_time_period: z_score_time_period, stddev_over_time_period: z_score_time_period },
                   record: 'mintel:workload:cpu_usage_anomaly:z_score_%(z_score_period)s' % (z_score_time_period),
                 }
                 for z_score_time_period in ['1d']
               ],
      },
    ],
  },
}
