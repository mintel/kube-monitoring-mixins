{
  // Define the default configuration values
  _config+: {
    slo_operator: {
      recording_rules_interval: '30s',
      recording_rules_sum_by_labels: 'app_mintel_com_owner, job, namespace, service_level, slo',
      recording_rules_extra_labels: {},
    },
  },

  prometheusRules+:: {
    groups+: [
      {
        name: 'slo-operator.rules',
        rules: [
          {
            // This rule is bad since, because of the evaluation interval to 30s , we  loose a lot of precision compared to the real data
            record: 'sli:error_ratio_above_slo_bool:ok',
            labels: $._config.slo_operator.recording_rules_extra_labels,
            expr: |||
              (
                sum by (%(recording_rules_sum_by_labels)s) (increase(service_level_sli_result_error_ratio_total{}[%(recording_rules_interval)s]))
                /
                sum by (%(recording_rules_sum_by_labels)s) (increase(service_level_sli_result_count_total{}[%(recording_rules_interval)s]))
              ) < bool sum by (%(recording_rules_sum_by_labels)s) (1 - service_level_slo_objective_ratio{})
            ||| % $._config.slo_operator,
          },
        ],
      },
    ],
  },

}
