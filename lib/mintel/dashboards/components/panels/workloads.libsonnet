local commonPanels = import 'components/panels/common.libsonnet';
{
  workloadStatus(thresholdPercent=50, max=100, span=4)::
    commonPanels.timeseries(
      title='Workloads Status',
      description='Percentage of instances up (by workload)',
      span=span,
      max=max,
      format='percent',
      legend_show=false,
      // Fix legendFormat to display deployment/statefulset (needs relabel)
      thresholds=[
        {'value': thresholdPercent,
        'colorMode': 'critical',
        'op': 'lt',
        'fill': true,
        'line': true
      }],
      query=|||
        sum by (deployment, statefulset)
          (
            100 * (kube_deployment_status_replicas_available{namespace=~"$namespace"}) / (kube_deployment_spec_replicas{namespace=~"$namespace"})
            or
            100 * (kube_statefulset_status_replicas_ready{namespace=~"$namespace"}) / (kube_statefulset_status_replicas{namespace=~"$namespace"})
          )
      |||
    ),
}
