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
  namespace(current, hide=false):: template.new(
    'namespace',
    'Prometheus',
    'label_values(kube_pod_container_info,namespace)',
    label='Namespace',
    refresh='load',
    current=current,
    hide=hide,
  ),
  app_service:: template.new(
    'service',
    'Prometheus',
    'label_values(kube_service_labels{namespace="$namespace"}, label_app_kubernetes_io_instance)',
    label='Service',
    refresh='load',
  ),

  app_deployment:: template.new(
    'deployment',
    'Prometheus',
    'label_values(kube_deployment_labels{namespace="$namespace"}, deployment)',
    label='Deployment',
    refresh='load',
  ),

  celery_task_name:: template.new(
    'celery_task_name',
    'Prometheus',
    'label_values(celery_tasks_total,name)',
    label='Celery Task Name',
    refresh='load',
  ),

  celery_task_state:: template.new(
    'celery_task_state',
    'Prometheus',
    'label_values(celery_tasks_total,state)',
    label='Celery Task State',
    refresh='load',
  ),

  cost_cpu(current, hide=false):: template.new(
    'cost_cpu',
    'Prometheus',
    '18.7',
    label= "CPU",
    refresh='load',
  ),

}
