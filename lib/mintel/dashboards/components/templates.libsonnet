local grafana = import 'grafonnet/grafana.libsonnet';
local template = grafana.template;

{

  ds:: template.datasource(
    'ds',
    'prometheus',
    'Prometheus',
    hide=true,
  ),
  generic_up_label_values(selector, name, labelSelector, includeAll=true, multiValue=false, allValues='.*'):: template.new(
    name,
    'Prometheus',
    std.format('label_values(up{%s}, %s)', [selector, labelSelector]),
    label=name,
    allValues=allValues,
    current='',
    includeAll=includeAll,
    multi=multiValue,
    refresh='time',
    sort=0,
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
  app_service(service=''):: template.new(
    'service',
    'Prometheus',
    'label_values(kube_service_labels{namespace="$namespace", service=~".*%(service)s.*"}, label_app_kubernetes_io_instance)' % (service),
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
  cost_discount(current, hide=false):: template.custom(
    'costDiscount',
    current,
    current=current,
    label='Disc.',
    hide=hide,
  ),
  cost_cpu(current, hide=false):: template.custom(
    'costcpu',
    current,
    current=current,
    label='CPU',
    hide=hide,
  ),
  cost_pcpu(current, hide=false):: template.custom(
    'costpcpu',
    current,
    current=current,
    label='PE CPU',
    hide=hide,
  ),
  cost_storage_ssd(current, hide=false):: template.custom(
    'costStorageSSD',
    current,
    current=current,
    label='SSD',
    hide=hide,
  ),
  cost_storage_standard(current, hide=false):: template.custom(
    'costStorageStandard',
    current,
    current=current,
    label='Storage',
    hide=hide,
  ),
  cost_ram(current, hide=false):: template.custom(
    'costram',
    current,
    current=current,
    label='RAM',
    hide=hide,
  ),
  cost_pram(current, hide=false):: template.custom(
    'costpram',
    current,
    current=current,
    label='PE RAM',
    hide=hide,
  ),
  cost_namespace(current, hide=false):: template.new(
    'namespace',
    'Prometheus',
    'query_result(sum(container_memory_working_set_bytes{namespace!=""}) by (namespace))',
    regex='/namespace="(.*?)(")/',
    current=current,
    label='NS',
    refresh='load',
  ),
  cost_pod(current, hide=false):: template.new(
    'pod',
    'Prometheus',
    'query_result(sum(container_memory_working_set_bytes{namespace="$namespace"}) by (pod))',
    regex='/pod="(.*?)(")/',
    current=current,
    label='Pod',
    refresh='load',
  ),
  unaccounted_node_storage(current, hide=false):: template.custom(
    'unaccountedNodeStorage',
    current,
    current=current,
    label='NS',
    hide=hide,
  ),
  slo_operator_slo_namespaces(current='', hide=''):: template.new(
    'slo_namespace',
    'Prometheus',
    'label_values(service_level_sli_result_count_total{}, namespace)',
    label='SLO Namespace',
    refresh='time',
    current=current,
    hide=hide,
  ),
  slo_operator_services(current='', hide=''):: template.new(
    'slo_service',
    'Prometheus',
    'label_values(service_level_sli_result_count_total{namespace="$slo_namespace"}, service_level)',
    label='SLO Service',
    refresh='time',
    current=current,
    hide=hide,
  ),
  slo_operator_slo(current='', hide=''):: template.new(
    'slo',
    'Prometheus',
    'label_values(service_level_sli_result_count_total{namespace="$slo_namespace", service_level="$slo_service"}, slo)',
    label='SLO',
    refresh='time',
    multi=true,
    includeAll=true,
    current=current,
    hide=hide,
  ),
  slo_availability_span(current='7d'):: template.new(
    'slo_availability_span',
    null,
    '10m,1h,1d,7d,21d,30d,90d',
    label='Availability Span',
    current=current,
  ) {
    type: 'custom',
    options: [
      {
        selected: false,
        text: '10m',
        value: '10m',
      },
      {
        selected: false,
        text: '1h',
        value: '1h',
      },
      {
        selected: false,
        text: '1d',
        value: '1d',
      },
      {
        selected: true,
        text: '7d',
        value: '7d',
      },
      {
        selected: false,
        text: '21d',
        value: '21d',
      },
      {
        selected: false,
        text: '30d',
        value: '30d',
      },
      {
        selected: false,
        text: '90d',
        value: '90d',
      },
    ],
  },
  omni_dashboard_id:: template.new(
    'dashboard_id',
    'Prometheus',
    'label_values(django_widget_request_time_count{namespace="$namespace"},dashboard_id)',
    label='Dashboard ID',
    refresh='time',
  ),
 }
