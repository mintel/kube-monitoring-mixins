// Import the Constants
local constants = import '../constants.libsonnet';

////////////////////
// Requests Rules //
////////////////////

// Main Recording rule for measuring Rate of requests by code
// sli:ingress:backend_responses_total_by_code:rate{backend="sandbox-podinfo-http",code="5xx",ingress_type="haproxy",job="haproxy-exporter",pod="haproxy-ingress-98d465f5-klsxf",rate_interval="2m",scope="sli_slo"}
local generate_sli_ingress_responses_total_rate_recording_rule(type) =
  (
    // requires jsonnet 0.15 to use // if std.member(['haproxy', 'contour'], type) then
    if type == 'haproxy' || type == 'contour' then
      {
        record: constants.sli_slo.sli_ingress_responses_total_rate_metric_name,
        expr: |||
          sum by (%(responses_total_rate_sum_by_labels)s)
            (rate(%(responses_total_metric_name)s{%(responses_exclude_selector)s, %(job_selector)s}[%(interval)s]))
        ||| % constants.sli_slo[type],
        labels+: {
          rate_interval: constants.sli_slo[type].interval,
          ingress_type: type,
          scope: 'sli_slo',
        },
      }
    else {}
  );

// Recording rule to measure Ratio of rate of requests by code / total of requests
// sli:ingress:backend_responses_ratio_by_code:rate{backend="sandbox-podinfo-http",code="5xx",ingress_type="haproxy",job="haproxy-exporter",rate_interval="2m",scope="sli_slo"}
local generate_sli_ingress_responses_total_ratio_rate_recording_rule(type) =
  (
    if type == 'haproxy' || type == 'contour' then
      {
        record: constants.sli_slo.sli_ingress_responses_total_ratio_rate_metric_name,
        expr: |||
          sum by ( %(responses_total_ratio_rate_sum_by_labels)s, %(responses_total_error_label)s )
            ( %(sli_ingress_responses_total_rate_metric_name)s{%(job_selector)s} )
          /
          ignoring( %(responses_total_error_label)s ) group_left()
            sum by( %(responses_total_ratio_rate_sum_by_labels)s ) ( %(sli_ingress_responses_total_rate_metric_name)s{%(job_selector)s} )
        ||| % (constants.sli_slo[type] { sli_ingress_responses_total_rate_metric_name: constants.sli_slo.sli_ingress_responses_total_rate_metric_name }),
        labels+: {
          rate_interval: constants.sli_slo[type].interval,
          scope: 'sli_slo',
        },
      }
    else {}

  );

// Recording rule to measure percentage rate of errors (5xx) , normalized to include the common service label
// sli:ingress:backend_responses_errors_percentage:rate{backend="sandbox-podinfo-http",backend_service="sandbox-podinfo-http",ingress_type="haproxy",job="haproxy-exporter",rate_interval="2m",scope="sli_slo"}
local generate_sli_ingress_responses_errors_percentage_rate_recording_rule(type) =
  (
    if type == 'haproxy' || type == 'contour' then
      {
        record: constants.sli_slo.sli_ingress_responses_errors_ratio_rate_metric_name,
        expr: |||
          label_replace(
            100 *
            sum by( %(responses_errors_ratio_rate_sum_by_labels)s )
              ( %(sli_ingress_responses_total_ratio_rate_metric_name)s{%(responses_total_error_label)s="%(responses_total_error_value)s", %(job_selector)s} ),
            "%(common_service_label)s",
            "$1",
            "%(service_label)s",
            "(.*)"
          )
        ||| % (constants.sli_slo[type] {
                 sli_ingress_responses_total_ratio_rate_metric_name: constants.sli_slo.sli_ingress_responses_total_ratio_rate_metric_name,
                 common_service_label: constants.sli_slo.common_service_label,
               }),
        labels+: {
          rate_interval: constants.sli_slo[type].interval,
          scope: 'sli_slo',
        },
      }
    else {}

  );

////////////////////
// Latency Rules  //
////////////////////


// Recording rule for rate of latency of requests to be used to calculate quantiles, normalized to include the common service label and normalized to milliseconds
//
local generate_sli_ingress_latency_rate_recording_rule(type) =
  (
    if type == 'haproxy' || type == 'contour' then
      {
        record: constants.sli_slo.sli_ingress_responses_latency_rate_metric_name,
        expr: |||
          label_replace(
            sum (
              rate(%(responses_latency_duration_metric_name)s{%(responses_exclude_selector)s, %(job_selector)s}[%(interval)s])
            ) by (%(service_label)s, job, le),
            "%(common_service_label)s",
            "$1",
            "%(service_label)s",
            "(.*)"
          )
        ||| % (constants.sli_slo[type] {
                 common_service_label: constants.sli_slo.common_service_label,
               }),
        labels+: {
          scope: 'sli_slo',
          rate_interval: constants.sli_slo[type].interval,
          ingress_type: type,
        },
      }
    else [{}]
  );

// Recording rule for percentile of latency of requests, normalized to milliseconds
//
local generate_sli_ingress_latency_precentile_recording_rule(type) =
  (
    [{
      record: std.format('%s%s', [constants.sli_slo.sli_ingress_responses_latency_percentile_metric_name, std.substr(quantile, 2, 2)]),
      expr: |||
        %(responses_latency_multiplier)s *
        histogram_quantile(%(quantile)s,
          %(sli_ingress_responses_latency_rate_metric_name)s{ingress_type="%(type)s"}
        )
      ||| % (constants.sli_slo[type] {
               sli_ingress_responses_latency_rate_metric_name: constants.sli_slo.sli_ingress_responses_latency_rate_metric_name,
               quantile: quantile,
               type: type,
             }),
      labels+: {
        scope: 'sli_slo',
        quantile: quantile,
      },
    } for quantile in constants.sli_slo.sli_quantiles]
  );


// Recording rule to generate SLO Compliance metrics
local generate_slo_compliance_recording_rules(id, o) =
  (
    // Validate object o
    assert std.objectHas(o, 'backend');
    assert std.objectHas(o, 'slo');
    assert std.objectHas(o.backend, 'type');
    assert std.objectHas(o.backend, 'namespace');
    assert std.objectHas(o.backend, 'service');
    assert std.objectHas(o.backend, 'port');
    assert std.objectHas(o.slo, 'slo_target_percentage');
    assert std.objectHas(o.slo, 'slo_target_time_window_days');
    assert std.objectHas(o.slo, 'error_ratio_threshold');
    assert std.objectHas(o.slo, 'latency_percentile');
    assert std.objectHas(o.slo, 'latency_threshold_milliseconds');

    local common_labels = {
      scope: 'sli_slo',
      service_id: id,
      ingress_type: o.backend.type,
      namespace: o.backend.namespace,
      service: o.backend.service,
      port: o.backend.port,
    };

    local service_name = std.format(constants.sli_slo[o.backend.type].service_name_format, [o.backend.namespace, o.backend.service, o.backend.port]);

    local slo_error_ratio_threshold_rule = {
      record: constants.sli_slo.slo_ingress_responses_errors_threshold_metric_name,
      labels+: common_labels,
      expr: |||
        %(error_ratio_threshold)s
      ||| % ({
               error_ratio_threshold: o.slo.error_ratio_threshold,
             }),
    };

    local slo_latency_threshold_rule = {
      record: constants.sli_slo.slo_ingress_responses_latency_threshold_metric_name,
      labels+: common_labels,
      expr: |||
        %(latency_threshold_milliseconds)s
      ||| % ({
               latency_threshold_milliseconds: o.slo.latency_threshold_milliseconds,
             }),
    };


    local slo_error_ratio_rule = {
      record: constants.sli_slo.slo_ingress_responses_errors_ok_metric_name,
      labels+: common_labels,
      expr: |||
        %(sli_ingress_responses_errors_ratio_rate_metric_name)s{ingress_type="%(type)s", backend_service="%(service_name)s"} < bool %(error_ratio_threshold)s
      ||| % ({
               sli_ingress_responses_errors_ratio_rate_metric_name: constants.sli_slo.sli_ingress_responses_errors_ratio_rate_metric_name,
               type: o.backend.type,
               service_name: service_name,
               error_ratio_threshold: o.slo.error_ratio_threshold,
             }),
    };

    local slo_latency_rule = {
      record: constants.sli_slo.slo_ingress_responses_latency_ok_metric_name,
      labels+: common_labels,
      expr: |||
        %(sli_ingress_responses_latency_percentile_metric_name)s{ingress_type="%(type)s", backend_service="%(service_name)s"} < bool %(latency_threshold_milliseconds)s
      ||| % ({
               sli_ingress_responses_latency_percentile_metric_name: std.format('%s%s', [constants.sli_slo.sli_ingress_responses_latency_percentile_metric_name, o.slo.latency_percentile]),
               type: o.backend.type,
               service_name: service_name,
               latency_threshold_milliseconds: o.slo.latency_threshold_milliseconds,
             }),
    };

    // Return list of rules
    [slo_error_ratio_rule, slo_latency_rule, slo_error_ratio_threshold_rule, slo_latency_threshold_rule]
  );

// Recording rule to generate SLO Compliance common metrics ( mostly useful for grafana )
local generate_slo_compliance_common_recording_rules() =
  (
    // Ignore QUANTILE ( which only is on one of the metrics ) and JOB ( which for haproxy differ between one metric and the other )
    local slo_combined_rule = {
      record: constants.sli_slo.slo_ingress_responses_combined_metric_name,
      expr: |||
        %(slo_ingress_responses_errors_ok_metric_name)s
        *
        ignoring (quantile, job) %(slo_ingress_responses_latency_ok_metric_name)s
      ||| % ({
               slo_ingress_responses_latency_ok_metric_name: constants.sli_slo.slo_ingress_responses_latency_ok_metric_name,
               slo_ingress_responses_errors_ok_metric_name: constants.sli_slo.slo_ingress_responses_errors_ok_metric_name,
             }),
    };

    // Return list of rules
    [slo_combined_rule]
  );


////////////////////
// Jsonnet Rules  //
////////////////////
{
  // Define the service SLI and SLO
  _config+: {
    sli_slo: {},
  },

  //prometheusRules+:: {
  prometheusRules+: {
    groups+: [
      {
        name: 'slislo.rules',
        rules: [
                 // Common Recording Rules
                 generate_sli_ingress_responses_total_rate_recording_rule('haproxy'),
                 generate_sli_ingress_responses_total_rate_recording_rule('contour'),
                 generate_sli_ingress_responses_total_ratio_rate_recording_rule('haproxy'),
                 generate_sli_ingress_responses_total_ratio_rate_recording_rule('contour'),
                 generate_sli_ingress_responses_errors_percentage_rate_recording_rule('haproxy'),
                 generate_sli_ingress_responses_errors_percentage_rate_recording_rule('contour'),
                 generate_sli_ingress_latency_rate_recording_rule('haproxy'),
                 generate_sli_ingress_latency_rate_recording_rule('contour'),
               ] +
               generate_sli_ingress_latency_precentile_recording_rule('haproxy') +
               generate_sli_ingress_latency_precentile_recording_rule('contour') +
               std.flattenArrays([generate_slo_compliance_recording_rules(id, $._config.sli_slo[id]) for id in std.objectFields($._config.sli_slo)]) +
               generate_slo_compliance_common_recording_rules(),
      },
    ],
  },

}
