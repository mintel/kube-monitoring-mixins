local grafana = import 'grafonnet/grafana.libsonnet';
local template = grafana.template;

{

  ds:: template.datasource(
    'ds',
    'prometheus',
    'Prometheus',
    hide=true,
  ),
  node:: template.new(
    'node',
    'Prometheus',
    'query_result(count(count_over_time(kube_node_labels{cluster="$cluster"}[1w])) by (label_kubernetes_io_hostname))',
    label='Node',
    allValues='.*',
    current='',
    includeAll=true,
    refresh='time',
    regex='/.*="(.*)".*/',
    sort=0,
  ),
  namespace:: template.new(
    'namespace',
    'Prometheus',
    'label_values(kube_pod_container_info,namespace)',
    label='Namespace',
    refresh='load',
  ),
  app_service:: template.new(
    'service',
    'Prometheus',
    'label_values(kube_service_labels, label_app_kubernetes_io_instance)',
    label='Service',
    refresh='load',
  ),
}
