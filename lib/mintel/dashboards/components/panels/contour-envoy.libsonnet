local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  // contour envoy metric like
  // Unit is millisecond
  // envoy_cluster_name is "namespace_deployment_portnumber"
  // envoy_cluster_upstream_rq_time_bucket{app_mintel_com_owner="sre",endpoint="stats",envoy_cluster_name="ingress-controller_service-stats_9001",instance="10.20.2.4:8002",job="contour-ingress",le="0.5",namespace="ingress-controller",pod="envoy-69d5c6d78-kt7sb",service="envoy-internal"}
  // TODO: Use namespace / deployment to create cluster selector ?
  clusterLatencyTimeseries(clusterSelector, interval='5m', span=12)::
    local config = {
      //clusterSelector: std.format('${%(namespaceVarName)s}_${%(workloadVarName)s}_[0-9]+', [namespace, workload]),
      clusterSelector: clusterSelector,
      interval: interval,
    };

    commonPanels.latencyTimeseries(
      title='Contour/Envoy Cluster Latency',
      description='Percentile Latency from Contour/Envoy Cluster',
      yAxisLabel='Latency',
      format='ms',
      span=span,
      nullPointMode='null as zero',
      legend_show=true,
      height=300,
      query=|||
        histogram_quantile(0.95,
          sum(
            rate(
              envoy_cluster_upstream_rq_time_bucket{envoy_cluster_name=~"%(clusterSelector)s"}[%(interval)s]
            )
          ) by (envoy_cluster_name,job,le)
        )
      ||| % config,
      legendFormat='p95 {{ envoy_cluster_name }}',
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.75,
            sum(
              rate(
                envoy_cluster_upstream_rq_time_bucket{envoy_cluster_name=~"%(clusterSelector)s"}[%(interval)s]
              )
            ) by (envoy_cluster_name,job,le)
          )
        ||| % config,
        legendFormat='p75 {{ envoy_cluster_name }}',
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.50,
            sum(
              rate(
                envoy_cluster_upstream_rq_time_bucket{envoy_cluster_name=~"%(clusterSelector)s"}[%(interval)s]
              )
            ) by (envoy_cluster_name,job,le)
          )
        ||| % config,
        legendFormat='p50 {{ envoy_cluster_name }}',
        intervalFactor=2,
      )
    ),

  // envoy_cluster_upstream_rq_xx{app_mintel_com_owner="sre",endpoint="stats",envoy_cluster_name="sandbox_podinfo_9898",envoy_response_code_class="2",instance="10.20.0.3:8002",job="contour-ingress",namespace="ingress-controller",pod="envoy-69d5c6d78-m9vdq",service="envoy-internal"}
  clusterResponsesTimeseries(clusterSelector, interval='5m', span=12)::
    local config = {
      clusterSelector: clusterSelector,
      interval: interval,
    };

    commonPanels.timeseries(
      title='Contour/Envoy cluster Responses /s',
      description='Contour/Envoy cluster Total Responses',
      yAxisLabel='Num Responses/s',
      format='reqps',
      span=span,
      nullPointMode='null as zero',
      legend_show=true,
      height=300,
      query=|||
        sum(
          rate(
            envoy_cluster_upstream_rq_xx{envoy_cluster_name=~"%(clusterSelector)s"}[%(interval)s]
          )
        ) by (envoy_response_code_class)
      ||| % config,
      legendFormat='{{ envoy_response_code_class }}xx',
      intervalFactor=2,
    ) + {
      overrides: {
        seriesOverrides: [
          {
            alias: '/^5$/',
            zindex: 2,
            color: 'rgb(232, 0, 4)',
            nullPointMode: 'null as zero',
          },
        ],
      },
    },
}
