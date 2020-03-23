local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{
  cpuUtilisation(span=2)::

    commonPanels.gauge(
      title='CPU Utilisation',
      gaugeMaxValue=100,
      thresholds='30, 80',
      colors= [
          "rgba(245, 54, 54, 0.9)",
          "rgba(50, 172, 45, 0.97)",
          "#c15c17"],
      query=|||
        sum (rate (container_cpu_usage_seconds_total{id!="/",service="kubelet"}[1m]))
        /
        sum (machine_cpu_cores{service="kubelet"}) * 100
      |||,
    ),

  cpuRequests(span=2)::

    commonPanels.gauge(
      title='CPU Requests',
      gaugeMaxValue=100,
      thresholds='30, 80',
      colors= [
          "rgba(245, 54, 54, 0.9)",
          "rgba(50, 172, 45, 0.97)",
          "#c15c17"],
      query=|||
        (sum(kube_pod_container_resource_requests_cpu_cores) / sum (kube_node_status_allocatable_cpu_cores)) * 100
      |||,
    ),

}