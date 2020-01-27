local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local common = import 'common.libsonnet';
{
  
  panels+:: {

    djangoRequestLatency: common.graphPanel {
      title: 'Request Latency',
      description: 'Request Latency with Quantiles',
      span: 5,
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
      span: 5,
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

    djangoRequestsByMethodView: common.graphPanel {
      title: 'Requests by Method/View',
      description: 'Requests by Method/View over Time',
      span: 5,
      }
      .addTarget(prometheus.target(
        |||
          sum(
            irate(
              django_http_requests_total_by_view_transport_method_total{namespace=~"$namespace", service=~"^$service$",view!~"prometheus-django-metrics|healthcheck"}[5m]))
          by(method, view)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{method}}/{{view}}',
      )),

    djangoDatabaseOps: common.graphPanel {
    title: 'Database Operations',
    description: 'Rate of Django Databases Operations',
    span: 5,
    }.addTarget(
      grafana.prometheus.target(
        |||
          sum(rate(django_db_execute_total{namespace=~"$namespace", service=~"^$service$"}[1m])) by (vendor)
        |||,
        legendFormat='{{vendor}}'
      )
    ),

    djangoResponseStat(status, status_query): common.singlestat {
    title: '%(status)s Responses' % status,
    description: '%(status)s Responses' % status,
    span: 2,
    }.addTarget(
      grafana.prometheus.target(
        |||
          sum(rate(django_http_responses_total_by_status_total{status=~"%(status_query)s", namespace=~"$namespace", service=~"^$service$"}[5m]))
        ||| % status_query,
      )
    ),

    commonContainerMemoryUsage: common.graphPanel {
    title: 'Per Instance Memory',
    description: 'Per instance memory (showing only "main" container)',
    span: 5,
    }.addTarget(
      grafana.prometheus.target(
        |||
          container_memory_usage_bytes{container_name="main", pod_name=~"$service-.*"}
        |||,
        legendFormat='{{pod_name}}'
      )
    ),

    commonContainerCPUUsage: common.graphPanel {
    title: 'Per Instance CPU',
    description: 'Per instance CPU (showing only "main" container)',
    span: 5,
    }.addTarget(
      grafana.prometheus.target(
        |||
          rate(container_cpu_usage_seconds_total{container_name="main", pod_name=~"$service.*"}[5m])
        |||,
        legendFormat='{{pod_name}}'
      )
    ),

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