local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local common = import 'common.libsonnet';

{

  panels+:: {

    djangoRequestLatency: common.graphPanel {
      title: 'Request Latency',
      description: 'Request Latency with Quantiles',
      span: 4,
      }
      .addTarget(prometheus.target(
        |||
          histogram_quantile(0.50, 
            sum(rate(
              django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m])
            ) by (job, le)
          )
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='quantile=50',
      ))
      .addTarget(prometheus.target(
        |||
          histogram_quantile(0.95, 
            sum(rate(
              django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m])
            ) by (job, le)
          )
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='quantile=95',
      ))
      .addTarget(prometheus.target(
        |||
          histogram_quantile(0.99, 
            sum(rate(
              django_http_requests_latency_seconds_by_view_method_bucket{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m])
            ) by (job, le)
          )
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='quantile=99',
      )),
    djangoResponseStatus: common.graphPanel {
      title: 'Response Status',
      description: 'Responses by HTTP Status Code',
      span: 4,
      }
      .addTarget(prometheus.target(
        |||
          sum(
            rate(
                django_http_responses_total_by_status_total{namespace=~"$namespace", service=~"^$service$", view!~"prometheus-django-metrics|healthcheck"}[5m])) by(status)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{status}}',
      )),
    commonPodsAvailableSlots: common.graphPanel {
    title: 'Number of Pods',
    description: 'Number of Pods up over time',
    }.addTarget(
      grafana.prometheus.target(
        |||
          sum(up{service="$service", namespace="$namespace"})
        |||
      )
    ),
  }
}