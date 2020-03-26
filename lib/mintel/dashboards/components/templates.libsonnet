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
  cost_discount(current, hide=false):: template.new(
    'costDiscount',
    'Prometheus',
    '$._config.cost_discount',
    current=current,
    label= "Disc.",
    refresh='load',
    hide=hide,
  ),
  cost_cpu(current, hide=false):: template.new(
    'costcpu',
    'Prometheus',
    '$._config.cost_cpu',
    current=current,
    label= "CPU",
    refresh='load',
    hide=hide,
  ),
  cost_pcpu(current, hide=false):: template.new(
    'costpcpu',
    'Prometheus',
    '$._config.cost_pcpu',
    current=current,
    label= "PE CPU",
    refresh='load',
    hide=hide,
  ),
  cost_storage_ssd(current, hide=false):: template.new(
    'costStorageSSD',
    'Prometheus',
    '$._config.cost_storage_ssd',
    current=current,
    label= "SSD",
    refresh='load',
    hide=hide,
  ),
  cost_storage_standard(current, hide=false):: template.new(
    'costStorageStandard',
    'Prometheus',
    '$._config.cost_storage_standard',
    current=current,
    label= "Storage",
    refresh='load',
    hide=hide,
  ),
  cost_ram(current, hide=false):: template.new(
    'costram',
    'Prometheus',
    '$._config.cost_ram',
    current=current,
    label= "RAM",
    refresh='load',
    hide=hide,
  ),
  cost_pram(current, hide=false):: template.new(
    'costpram',
    'Prometheus',
    '$._config.cost_pram',
    current=current,
    label= "PE RAM",
    refresh='load',
    hide=hide,
  ),
  cost_namespace(current, hide=false):: template.new(
    'namespace',
    'Prometheus',
    'query_result(sum(container_memory_working_set_bytes{namespace!=""}) by (namespace))',
    regex='/namespace=\"(.*?)(\")/',
    current=current,
    label='NS',
    refresh='load',
  ),
  cost_pod(current, hide=false):: template.new(
    'pod',
    'Prometheus',
    'query_result(sum(container_memory_working_set_bytes{namespace="$namespace"}) by (pod_name))',
    regex='/pod_name=\"(.*?)(\")/',
    current=current,
    label='Pod',
    refresh='load',
  ),
}
