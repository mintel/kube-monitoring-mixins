{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-http.rules',
        rules: [
          {
            expr: |||
              (
              sum by (service, app_mintel_com_owner) (rate(http_requests_total{status_code=~"5.."}[1m]))
              /  
              sum by (service, app_mintel_com_owner) (rate(http_requests_total[1m]))
              ) * 100
            |||,
            record: 'mintel:http_error_rate:percentage:1m',
          },
        ] + [
          {
            expr: |||
              histogram_quantile(%(quantile)s,
                sum without(instance, endpoint, job, pod) (rate(http_request_duration_seconds_bucket[1m]))
              )
            ||| % quantile,
            record: std.format('mintel:http_request_duration_seconds_quantile:%s', std.substr(quantile, 2, 2)),
          }
          for quantile in ['0.50', '0.75', '0.95', '0.99']
        ],
      },
    ],
  },
}