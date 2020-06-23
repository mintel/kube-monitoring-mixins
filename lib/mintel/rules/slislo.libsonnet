// Configuration for different Ingress Controller / Metrics sources
local const = {
  sli_ingress_responses_total_rate_metric_name: 'sli:ingress:backend_responses_total_by_code:rate',
  sli_ingress_responses_total_ratio_rate_metric_name: 'sli:ingress:backend_responses_total_by_code:ratio_rate',
  sli_ingress_responses_errors_ratio_rate_metric_name: 'sli:ingress:backend_responses_errors:ratio_rate',
  common_service_label: 'backend_service',
  haproxy: {
    job_name: 'haproxy-exporter',
    service_label: 'backend',
    responses_total_metric_name: 'haproxy_backend_http_responses_total',
    responses_total_exclude_selector: 'backend!~"(error|stats|.*default-backend)"',
    responses_total_error_label: 'code',
    responses_total_error_value: '5xx',
    responses_total_rate_sum_by_labels: 'job, code, backend, pod',
    responses_total_ratio_rate_sum_by_labels: 'job, ingress_type, backend',
    responses_errors_ratio_rate_sum_by_labels: 'job, ingress_type, backend',
    interval: '2m',
  },
  contour: {
    job_name: 'contour-ingress',
    service_label: 'envoy_cluster_name',
    responses_total_metric_name: 'envoy_cluster_upstream_rq_xx',
    responses_total_exclude_selector: 'envoy_cluster_name!~"(ingress-controller_contour_8001)"',
    responses_total_error_label: 'envoy_response_code_class',
    responses_total_error_value: '5',
    responses_total_rate_sum_by_labels: 'job, envoy_response_code_class, envoy_cluster_name, pod',
    responses_total_ratio_rate_sum_by_labels: 'job, ingress_type, envoy_cluster_name',
    responses_errors_ratio_rate_sum_by_labels: 'job, ingress_type, envoy_cluster_name',
    interval: '1m',
  },
};

// Generate the Top Level recording rules for SLI on backend responses based on the ingress type
local generate_sli_ingress_responses_total_rate_recording_rule(type) =
  (
    // requires jsonnet 0.15 if std.member(['haproxy', 'contour'], type) then
    if type == 'haproxy' || type == 'contour' then
      {
        record: const.sli_ingress_responses_total_rate_metric_name,
        expr: |||
          sum by (%(responses_total_rate_sum_by_labels)s) (rate(%(responses_total_metric_name)s{%(responses_total_exclude_selector)s}[%(interval)s]))
        ||| % const[type],
        labels+: {
          rate_interval: const[type].interval,
          ingress_type: type,
        },
      }
    else {}
  );

// Generate By Code ratio metrics
// If the metrics set of the rate rule change then the ignore in this rule will need to be updated
local generate_sli_ingress_responses_total_ratio_rate_recording_rule(type) =
  (
    if type == 'haproxy' || type == 'contour' then
      {
        record: const.sli_ingress_responses_total_ratio_rate_metric_name,
        expr: |||
          sum by ( %(responses_total_ratio_rate_sum_by_labels)s, %(responses_total_error_label)s )
            ( %(sli_ingress_responses_total_rate_metric_name)s{job="%(job_name)s"} )
          /
          ignoring( %(responses_total_error_label)s ) group_left()
            sum by( %(responses_total_ratio_rate_sum_by_labels)s ) ( %(sli_ingress_responses_total_rate_metric_name)s{job="%(job_name)s"} )
        ||| % (const[type] { sli_ingress_responses_total_rate_metric_name: const.sli_ingress_responses_total_rate_metric_name }),
        labels+: {
          rate_interval: const[type].interval,
        },
      }
    else {}

  );

// Generate Errors ratio metrics
// Normalize Labels to include common service label
local generate_sli_ingress_responses_errors_ratio_rate_recording_rule(type) =
  (
    if type == 'haproxy' || type == 'contour' then
      {
        record: const.sli_ingress_responses_errors_ratio_rate_metric_name,
        expr: |||
          label_replace(
            sum by( %(responses_errors_ratio_rate_sum_by_labels)s )
              ( %(sli_ingress_responses_total_ratio_rate_metric_name)s{%(responses_total_error_label)s="%(responses_total_error_value)s",job="%(job_name)s"} ),
            "%(common_service_label)s",
            "$1",
            "%(service_label)s",
            "(.*)"
          )
        ||| % (const[type] {
                 sli_ingress_responses_total_ratio_rate_metric_name: const.sli_ingress_responses_total_ratio_rate_metric_name,
                 common_service_label: const.common_service_label,
               }),
        labels+: {
          rate_interval: const[type].interval,
        },
      }
    else {}

  );


// Generate Recording Rules
{
  // Common Specs to all rules
  common:: {
    labels+: {
      scope: 'sli_slo',
    },
  },

  prometheusRules+:: {
    groups+: [
      {
        name: 'slislo.rules',
        rules: [
          // Common Recording Rules
          generate_sli_ingress_responses_total_rate_recording_rule('haproxy') + $.common,
          generate_sli_ingress_responses_total_rate_recording_rule('contour') + $.common,
          generate_sli_ingress_responses_total_ratio_rate_recording_rule('haproxy') + $.common,
          generate_sli_ingress_responses_total_ratio_rate_recording_rule('contour') + $.common,
          generate_sli_ingress_responses_errors_ratio_rate_recording_rule('haproxy') + $.common,
          generate_sli_ingress_responses_errors_ratio_rate_recording_rule('contour') + $.common,
        ],
      },
    ],
  },

}
