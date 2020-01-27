local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local common = import 'common.libsonnet';

{

  panels+:: {

    requestLatency: common.graphPanel {
      title: 'Request Latency',
      description: 'Request Latency',
      span: 4,
      yaxes: [
        {
          format: 'ms',
          label: '',
          logBase: 1,
          min: null,
          max: null,
          show: true,
        },
        {
          format: 'short',
          label: null,
          logBase: 1,
          max: null,
          min: null,
          show: true
        }
      ],
      }.addTarget(prometheus.target(
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
      )),
    podsAvailableSlots: common.singlestat {
    title: 'Number of Pods',
    }.addTarget(
      grafana.prometheus.target(
        |||
          sum(up{service="$service", namespace="$namespace"})
        |||
      )
    ),
  }
}