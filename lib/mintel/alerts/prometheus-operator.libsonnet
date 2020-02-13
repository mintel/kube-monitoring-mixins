{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'prometheus-operator.alerts',
        rules: [
          // a similar rule already exist upstream
          //{
          //  alert: 'PrometheusOperatorReconcileErrors',
          //  annotations: {
          //    description: 'Prometheus Operator has failed to reconcile the CRD to kubernetes resources for more than 1 hour',
          //    summary: 'Prometheus Operator failed to reconcile  {{ $labels.controller }}',
          //    runbook_url: '%(runBookBaseURL)s/core/PrometheusOperatorReconcileErrors.md' % $._config,
          //  },
          //  expr: 'sum by (controller,job) (increase(prometheus_operator_reconcile_errors_total{%(prometheusOperatorJobFilter)s}[5m])) >0' % $._config,
          //  'for': '1h',
          //  labels: {
          //    severity: 'warning',
          //  },
          //},
          {
            alert: 'PrometheusOperatorRulesValidationErrors',
            annotations: {
              description: 'Prometheus Operator failed to validate rules',
              summary: 'Prometheus Operator failed to validate rules',
              runbook_url: '%(runBookBaseURL)s/core/PrometheusOperatorRulesValidationErrors.md' % $._config,
            },
            expr: 'increase(prometheus_operator_rule_validation_errors_total{%(prometheusOperatorJobFilter)s}[5m]) >0' % $._config,
            'for': '30m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
