local grafana = import 'grafonnet/grafana.libsonnet';
local template = grafana.template;

{
  namespace:: template.new(
    'namespace',
    '$PROMETHEUS_DS',
    'label_values(kube_pod_container_info,namespace)',
    refresh='load',
  ),
  ds:: template.datasource(
    'PROMETHEUS_DS',
    'prometheus',
    'Prometheus'
  ),
  Node:: template.new(
    'Node',
    '$PROMETHEUS_DS',
    'query_result(count(count_over_time(kube_node_labels{cluster="$cluster"}[1w])) by (label_kubernetes_io_hostname))',
    allValues='.*',
    current='',
    includeAll=true,
    refresh='time',
    regex='/.*="(.*)".*/',
    sort=0,
  ),
  fqdn(query, current):: template.new(
    'fqdn',
    '$PROMETHEUS_DS',
    'label_values(' + query + ', fqdn)',
    current=current,
    multi=true,
    refresh='load',
    sort=1,
  ),
}
