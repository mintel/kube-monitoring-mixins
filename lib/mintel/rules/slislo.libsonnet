local const = {
  sli_ingress_responses_total_rate_metric_name: 'ingress:backend_responses_total:rate',
  haproxy: {
    responses_total_metric_name: 'haproxy_backend_http_responses_total',
    responses_total_exclude_selector: 'backend!~"(error|stats|.*default-backend)"',
    responses_total_error_selector: 'code="5xx"',
    responses_total_rate_sum_by_labels: 'job, code, backend',
    interval: '2m',
  },
  contour: {
    responses_total_metric_name: 'envoy_cluster_upstream_rq_xx',
    responses_total_exclude_selector: '',
    responses_total_error_selector: 'envoy_response_code_class="5"',
    responses_total_rate_sum_by_labels: 'job, envoy_response_code_class, envoy_cluster_name',
    interval: '1m',
  },
};

// Generate the Top Level recording rules for SLI on backend responses based on the ingress type
local generate_sli_ingress_responses_total_rate_recording_rule(type) =
  (
    local rule = {
      record: const.sli_ingress_responses_total_rate_metric_name,
      labels+: {
        ingress_type: type,
      },
    };

    // requires jsonnet 0.15 if std.member(['haproxy', 'contour'], type) then
    if type == 'haproxy' || type == 'contour' then
      rule {
        expr: |||
          sum by (%(responses_total_rate_sum_by_labels)s) (rate(%(responses_total_metric_name)s{%(responses_total_exclude_selector)s}[%(interval)s]))
        ||| % const[type],
        labels+: {
          rate_interval: const[type].interval,
        },
      }
    else {}
  );


local generate_requests_error_ratio_recording_rule(type, backend_identifier, interval='2m') =
  (
    if type == 'haproxy' then
      {
        record: 'sli:ingress:backend_responses_total:rate',
        expr: |||
          sum by (%(responses_total_rate_sum_by_labels)s) (rate(%(responses_total_metric_name)s{%(responses_total_exclude_selector)s}[%(interval)s]))
        ||| % (const.haproxy { interval: interval }),
        labels: {
          rate_interval: interval,
          ingress_type: type,
        },
      }
    else if type == 'contour' then
      {
        record: 'sli:ingress:backend_responses_total:rate',
        expr: |||
          sum by (%(responses_total_rate_sum_by_labels)s) (rate(%(responses_total_metric_name)s{%(responses_total_exclude_selector)s}[%(interval)s]))
        ||| % (const.contour { interval: interval }),
        labels: {
          rate_interval: interval,
          ingress_type: type,
        },
      }
    else {}
  );


{
  // Common Specs to all rules
  common:: {
    labels+: {
      scope: 'sli_slo',
    },
  },

  // Rules Placeholder
  // prometheusRules+:: {
  prometheusRules+: {
    groups+: [
      {
        name: 'slislo.rules',
        rules: [
          generate_sli_ingress_responses_total_rate_recording_rule('haproxy') + $.common,
          generate_sli_ingress_responses_total_rate_recording_rule('contour') + $.common,
          //generate_requests_error_ratio_recording_rule('haproxy', 'kube-auth-dex-5443') + $.common,
          //generate_requests_error_ratio_recording_rule('contour', 'kube-auth-dex-5443') + $.common,
        ],
      },
    ],
  },

}
