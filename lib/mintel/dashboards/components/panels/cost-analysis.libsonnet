local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';

local namespaceDashboard = std.md5('cost-analysis-namespace-dashboard.json');
local podDashboard = std.md5('cost-analysis-pod-dashboard.json');

{

  overviewText(content)::
    commonPanels.text(
      title='',
      content=content,
      transparent=true,
    ),

  cpuUtilisation()::

    commonPanels.gauge(
      title='CPU Utilisation',
      description='This gauge shows the current CPU use vs CPU available',
      query=|||
        sum (rate (container_cpu_usage_seconds_total{id!="/",service="kubelet"}[$__interval])) / sum (machine_cpu_cores{service="kubelet"}) * 100
      |||,
      colors=[
        'rgba(245, 54, 54, 0.9)',
        'rgba(50, 172, 45, 0.97)',
        '#c15c17',
      ],
      format='percent',
      gaugeMaxValue=100,
      intervalFactor= 1,
      colorValue=true,
      decimals=2,
      thresholds='30, 80',
      valueFontSize='80%',
      valueName='current',
    ),

  cpuRequests()::

    commonPanels.gauge(
      title='CPU Requests',
      description='This panel shows current CPU reservation requests by applications, vs CPU available',
      query=|||
        (sum(kube_pod_container_resource_requests_cpu_cores) / sum (kube_node_status_allocatable_cpu_cores)) * 100
      |||,
      colors=[
        'rgba(245, 54, 54, 0.9)',
        'rgba(50, 172, 45, 0.97)',
        '#c15c17',
      ],
      format='percent',
      gaugeMaxValue=100,
      intervalFactor= 1,
      colorValue=true,
      decimals=2,
      thresholds='30, 80',
      valueFontSize='80%',
      valueName='current',
    ),

  cpuCost()::

    commonPanels.singlestat(
      title='CPU Cost',
      query=|||
        sum(((sum(kube_node_status_capacity_cpu_cores) by (node)
          * on (node) group_left (label_cloud_google_com_gke_preemptible) kube_node_labels{label_cloud_google_com_gke_preemptible="true"})
          * $costpcpu) or ((sum(kube_node_status_capacity_cpu_cores) by (node)
          * on (node) group_left (label_cloud_google_com_gke_preemptible) kube_node_labels{label_cloud_google_com_gke_preemptible!="true"})
          * ($costcpu - ($costcpu / 100 * $costDiscount))))
      |||,
      decimals=2,
      format='currencyUSD',
      legendFormat=' {{ node }}',
    ),

  storageCost(hostMountpointSelector)::
    local config = {
      hostMountpointSelector: hostMountpointSelector,
    };

    commonPanels.singlestat(
      title='Storage Cost (Cluster and PVC)',
      query=|||
        sum(sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"})
          by (persistentvolumeclaim, namespace, storageclass) + on (persistentvolumeclaim, namespace)
          group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
          by (persistentvolumeclaim, namespace)) / 1024 / 1024 / 1024 * $costStorageSSD
          + (sum (sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"})
          by (persistentvolumeclaim, namespace, storageclass) + on (persistentvolumeclaim, namespace)
          group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
          by (persistentvolumeclaim, namespace)) / 1024 / 1024 / 1024 or on() vector(0) )* $costStorageStandard
          + sum(node_filesystem_size_bytes{%(hostMountpointSelector)s} + $unaccountedNodeStorage) / 1024 / 1024 / 1024 * $costStorageSSD
      ||| % config,
      decimals=2,
      format='currencyUSD',
      intervalFactor= 1,
      legendFormat=' {{ node }}',
    ),

  tableNode()::

    commonPanels.table(
      title='Cluster Node Utilisation by CPU and RAM requests',
      description='This table shows the comparison of CPU and RAM requests by applications, vs the capacity of the node',
      styles=[
        {
          alias: 'RAM Requests',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
            'rgba(245, 54, 54, 0.9) ',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #A',
          thresholds: [
            '50',
            ' 80',
          ],
          type: 'number',
          unit: 'percent',
        },
        {
          alias: 'Node',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'node',
          thresholds: [],
          type: 'string',
          unit: 'short',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
        {
          alias: 'CPU Requests',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
            'rgba(245, 54, 54, 0.9)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #B',
          thresholds: [
            '50',
            ' 80',
          ],
          type: 'number',
          unit: 'percent',
        },
      ],
      query=|||
        (sum(kube_pod_container_resource_requests_memory_bytes) by (node) / sum(kube_node_status_allocatable_memory_bytes) by (node)) * 100
      |||,
      intervalFactor=1,
      legendFormat='{{ node }}',
    )
    .addTarget(
      promQuery.target(
        |||
          (sum(kube_pod_container_resource_requests_cpu_cores) by (node) / sum(kube_node_status_allocatable_cpu_cores) by (node)) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ node }}',
        intervalFactor=1,
      )
    ),

  ramUtilisation()::

    commonPanels.gauge(
      title='RAM Utilisation',
      description='This gauge shows current RAM use by RAM available',
      query=|||
        sum (container_memory_working_set_bytes{id!="/",service="kubelet"}) / sum (machine_memory_bytes{service="kubelet"}) * 100
      |||,
      colors=[
        'rgba(245, 54, 54, 0.9)',
        'rgba(50, 172, 45, 0.97)',
        '#c15c17',
      ],
      format='percent',
      gaugeMaxValue=100,
      intervalFactor= 1,
      colorValue=true,
      decimals=2,
      thresholds='30, 80',
      valueFontSize='80%',
      valueName='current',
    ),

  ramRequests()::

    commonPanels.gauge(
      title='RAM Requests',
      description='This panel shows current RAM reservation requests by applications, vs RAM available',
      query=|||
        (
          sum(kube_pod_container_resource_requests_memory_bytes)
            / sum(kube_node_status_allocatable_memory_bytes)) * 100
      |||,
      colors=[
        'rgba(245, 54, 54, 0.9)',
        'rgba(50, 172, 45, 0.97)',
        '#c15c17',
      ],
      format='percent',
      gaugeMaxValue=100,
      intervalFactor= 1,
      colorValue=true,
      decimals=2,
      thresholds='30, 80',
      valueFontSize='80%',
      valueName='current',
    ),

  ramCost()::

    commonPanels.singlestat(
      title='RAM Cost',
      query=|||
        sum(((
               sum(kube_node_status_capacity_memory_bytes) by (node)
                * on (node) group_left (label_cloud_google_com_gke_preemptible)
               kube_node_labels{label_cloud_google_com_gke_preemptible="true"}
             ) /1024/1024/1024 * $costpram)
           or
           ((
               sum(kube_node_status_capacity_memory_bytes) by (node)
                * on (node) group_left (label_cloud_google_com_gke_preemptible)
               kube_node_labels{label_cloud_google_com_gke_preemptible!="true"}
             ) /1024/1024/1024 * ($costram - ($costram / 100 * $costDiscount))))
      |||,
      decimals=2,
      format='currencyUSD',
      intervalFactor= 1,
      legendFormat=' {{ node }}',
    ),

  totalCost(hostMountpointSelector)::
    local config = {
      hostMountpointSelector: hostMountpointSelector,
    };

    commonPanels.singlestat(
      title='Total Cost',
      query=|||
        # CPU
        sum(((sum(kube_node_status_capacity_cpu_cores) by (node) * on (node) group_left (label_cloud_google_com_gke_preemptible)
        kube_node_labels{label_cloud_google_com_gke_preemptible="true"}) * $costpcpu)
        or ((sum(kube_node_status_capacity_cpu_cores) by (node) * on (node) group_left (label_cloud_google_com_gke_preemptible)
        kube_node_labels{label_cloud_google_com_gke_preemptible!="true"}) * ($costcpu - ($costcpu / 100 * $costDiscount)))) +
        # Storage
        sum (
        sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass)
        + on (persistentvolumeclaim, namespace) group_right(storageclass)
        sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)
        ) / 1024 / 1024 /1024 * $costStorageSSD +
        (sum (
        sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass)
        + on (persistentvolumeclaim, namespace) group_right(storageclass)
        sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)
        ) or on() vector(0)) / 1024 / 1024 /1024 * $costStorageStandard +
        sum(node_filesystem_size_bytes{%(hostMountpointSelector)s} + $unaccountedNodeStorage) / 1024 / 1024 / 1024 * $costStorageSSD +
        # RAM
        sum(((
            sum(kube_node_status_capacity_memory_bytes) by (node)
             * on (node) group_left (label_cloud_google_com_gke_preemptible)
            kube_node_labels{label_cloud_google_com_gke_preemptible="true"}) /1024/1024/1024 * $costpram
        )
        or
        ((
            sum(kube_node_status_capacity_memory_bytes) by (node)
             * on (node) group_left (label_cloud_google_com_gke_preemptible)
            kube_node_labels{label_cloud_google_com_gke_preemptible!="true"}
          ) /1024/1024/1024 * ($costram - ($costram / 100 * $costDiscount))
        ))
      ||| % config,
      decimals=2,
      format='currencyUSD',
      legendFormat=' {{ node }}',
    ),

  tableNamespace()::

    commonPanels.table(
      title='Namespace cost and utilisation analysis',
      styles=[
        {
          alias: 'Namespace',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(50, 172, 45, 0.97)',
            '#c15c17',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          link: true,
          linkTooltip: 'View namespace cost analysis',
          linkUrl: std.format('d/%s/mintel-cost-analysis-by-namespace?var-namespace=$__cell', namespaceDashboard),
          pattern: 'namespace',
          thresholds: [
            '30',
            '80',
          ],
          type: 'string',
          unit: 'currencyUSD',
        },
        {
          alias: 'RAM',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          pattern: 'Value #B',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #A',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
        {
          alias: 'Storage',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #C',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'Total',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #D',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
            '#bf1b00',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #E',
          thresholds: [
            '30',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
        {
          alias: 'RAM Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#ef843c ',
            'rgba(245, 54, 54, 0.9) ',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #F',
          thresholds: [
            '30',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
      ],
      query=|||
        (namespace:kube_pod_container_resource_requests_cpu_cores:sum * ($costcpu - ($costcpu / 100 * $costDiscount)) )
          +(sum(container_spec_cpu_shares{namespace!="",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu) by (namespace)
          or count(count(container_spec_cpu_shares{namespace!=""}) by (namespace)) by (namespace) -1)
      |||,
      intervalFactor=1,
      legendFormat='{{ namespace }}',
    )
    .addTarget(
      promQuery.target(
        |||
          (namespace:kube_pod_container_resource_requests_memory_bytes:sum/1024/1024/1024*($costram- ($costram
            / 100 * $costDiscount)))+(sum(container_spec_memory_limit_bytes{namespace!="",cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram)
            by (namespace) or count(count(container_spec_memory_limit_bytes{namespace!=""}) by (namespace)) by (namespace) -1)
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum (sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass) +
            on (persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
            by (persistentvolumeclaim, namespace)) by (namespace) / 1024 / 1024 / 1024 * $costStorageSSD
            or sum (sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"})
            by (persistentvolumeclaim, namespace, storageclass) + on (persistentvolumeclaim, namespace) group_right(storageclass)
            sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace))
            by (namespace) / 1024 / 1024 / 1024 * $costStorageStandard or count(count(container_spec_cpu_shares{namespace!=""}) by (namespace)) by (namespace) -1
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          # Add the CPU
            (namespace:kube_pod_container_resource_requests_cpu_cores:sum * ($costcpu - ($costcpu / 100 * $costDiscount)))
            + (sum(container_spec_cpu_shares{namespace!="",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu)
            by (namespace) or count(count(container_spec_cpu_shares{namespace!=""}) by (namespace)) by (namespace) -1) +
            # Add the RAM
            (namespace:kube_pod_container_resource_requests_memory_bytes:sum/1024/1024/1024*($costram- ($costram / 100 * $costDiscount)))
            + (sum(container_spec_memory_limit_bytes{namespace!="",cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram)
            by (namespace) or count(count(container_spec_memory_limit_bytes{namespace!=""}) by (namespace)) by (namespace) -1) +
            # Add the storage
            (sum (sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass)
            + on (persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
            by (persistentvolumeclaim, namespace)) by (namespace) / 1024 / 1024 / 1024 * $costStorageSSD
            or sum (sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass) +
            on (persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
            by (persistentvolumeclaim, namespace)) by (namespace) / 1024 / 1024 / 1024 * $costStorageStandard
            or count(count(container_spec_cpu_shares{namespace!=""}) by (namespace)) by (namespace) -1)
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          (sum by (namespace) (rate(container_cpu_usage_seconds_total{container!="",image!="",service="kubelet"}[$__interval]))
            /  ignoring(namespace) group_left() (sum (kube_node_status_allocatable_cpu_cores)) ) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(count(count(container_memory_working_set_bytes{namespace!=""}) by (pod, namespace)) by (pod, namespace) *
            on (pod, namespace) sum(avg_over_time(container_memory_working_set_bytes{namespace!=""}[$__interval]))
            by (pod, namespace)) by (namespace) / sum(container_spec_memory_limit_bytes{namespace!=""}) by (namespace) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    ),

  tablePVCCluster()::

    commonPanels.table(
      title='Persistent Volume Claims',
      styles=[
        {
          alias: 'Namespace',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'namespace',
          thresholds: [],
          type: 'string',
          unit: 'short',
        },
        {
          alias: 'PVC Name',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'persistentvolumeclaim',
          thresholds: [],
          type: 'number',
          unit: 'short',
        },
        {
          alias: 'Storage Class',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'storageclass',
          thresholds: [],
          type: 'number',
          unit: 'short',
        },
        {
          alias: 'Cost',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
      ],
      query=|||
        sum (sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass) +
          on(persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
          by (persistentvolumeclaim, namespace)) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 / 1024 * $costStorageSSD
          or sum (sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*"}) by (persistentvolumeclaim, namespace, storageclass) +
          on(persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes)
          by (persistentvolumeclaim, namespace)) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 / 1024 * $costStorageStandard
      |||,
      intervalFactor=1,
      legendFormat='{{ persistentvolumeclaim }}',
    ),

  tablePodCost()::

    commonPanels.table(
      title='Pod cost and utilisation analysis',
      styles=[
        {
          alias: 'Pod',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#c15c17',
            'rgba(245, 54, 54, 0.9)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          link: true,
          linkTooltip: 'Click to drill down into pod',
          linkUrl: std.format('d/%s/mintel-cost-analysis-by-pod?var-namespace=$namespace&var-pod=$__cell', podDashboard),
          pattern: 'pod',
          thresholds: [
            '30',
            '80',
          ],
          type: 'string',
          unit: 'currencyUSD',
        },
        {
          alias: 'RAM',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          pattern: 'Value #B',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #A',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
        {
          alias: 'Total',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #D',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
            '#bf1b00',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #E',
          thresholds: [
            '50',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
        {
          alias: 'RAM Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(50, 172, 45, 0.97)',
            '#c15c17',
            'rgba(245, 54, 54, 0.9)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #F',
          thresholds: [
            '50',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
        {
          alias: 'Storage - n/a',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #C',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
      ],
      query=|||
            (
              sum(container_spec_cpu_shares{namespace="$namespace",cloud_google_com_gke_preemptible!="true"}/1000*($costcpu - ($costcpu / 100 * $costDiscount))) by(pod)
              or
              count(
                count(container_spec_cpu_shares{namespace="$namespace"}) by(pod)
              ) by(pod) -1
            )

            +

            (
              sum(container_spec_cpu_shares{namespace="$namespace",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu) by(pod)
              or
              count(
                count(container_spec_cpu_shares{namespace="$namespace"}) by(pod)
              ) by(pod) -1
            )
      |||,
      intervalFactor=1,
      legendFormat='{{ pod }}',
    )
    .addTarget(
      promQuery.target(
        |||
          (
            sum(container_spec_memory_limit_bytes{namespace="$namespace",cloud_google_com_gke_preemptible!="true"}/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(pod)
            or
            count(
              count(container_spec_memory_limit_bytes{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )

          +

          (
            sum(container_spec_memory_limit_bytes{namespace="$namespace",cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram) by(pod)
            or
            count(
              count(container_spec_memory_limit_bytes{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          vector(0)
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          (
            sum(container_spec_cpu_shares{namespace="$namespace",cloud_google_com_gke_preemptible!="true"}/1000*($costcpu - ($costcpu / 100 * $costDiscount))) by(pod)
            or
            count(
              count(container_spec_cpu_shares{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )

          +

          (
            sum(container_spec_cpu_shares{namespace="$namespace",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu) by(pod)
            or
            count(
              count(container_spec_cpu_shares{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )

          # Now ram

          +
          (
            sum(container_spec_memory_limit_bytes{namespace="$namespace",cloud_google_com_gke_preemptible!="true"}/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(pod)
            or
            count(
              count(container_spec_memory_limit_bytes{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )

          +

          (
            sum(container_spec_memory_limit_bytes{namespace="$namespace",cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram) by(pod)
            or
            count(
              count(container_spec_memory_limit_bytes{namespace="$namespace"}) by(pod)
            ) by(pod) -1
          )
        |||,
        format='table',
        instant=true,
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
           sum(
              count(count(container_spec_cpu_shares{namespace="$namespace"}) by (pod)) by (pod)
              * on (pod)
              sum(irate(container_cpu_usage_seconds_total{namespace="$namespace"}[$__interval])) by (pod)
           ) by (pod) * 1000
           /
           sum(container_spec_cpu_shares{namespace="$namespace"}) by (pod) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ pod }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(
             count(count(container_memory_working_set_bytes{namespace="$namespace"}) by (pod)) by (pod)
             * on (pod)
             sum(avg_over_time(container_memory_working_set_bytes{namespace="$namespace"}[$__interval])) by (pod)
          ) by (pod)
          /
          sum(container_spec_memory_limit_bytes{namespace="$namespace"}) by (pod) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    ),

  tablePVCNamespace()::

    commonPanels.table(
      title='Persistent Volume Claims',
      styles=[
        {
          alias: 'Namespace',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'namespace',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
        {
          alias: 'PVC Name',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'persistentvolumeclaim',
          thresholds: [],
          type: 'number',
          unit: 'short',
        },
        {
          alias: 'Storage Class',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'storageclass',
          thresholds: [],
          type: 'number',
          unit: 'short',
        },
        {
          alias: 'Cost',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
      ],
      query=|||
        sum (sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass) +
          on (persistentvolumeclaim, namespace) group_right(storageclass)
          sum(kube_persistentvolumeclaim_resource_requests_storage_bytes{namespace=~"$namespace"})
          by (persistentvolumeclaim, namespace)) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 / 1024 * $costStorageSSD
          or sum (sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass) +
          on (persistentvolumeclaim, namespace) group_right(storageclass) sum(kube_persistentvolumeclaim_resource_requests_storage_bytes{namespace=~"$namespace"})
          by (persistentvolumeclaim, namespace)) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 / 1024 * $costStorageStandard
      |||,
      intervalFactor=1,
      legendFormat='{{ persistentvolumeclaim }}',
    ),

  graphOverallCPU()::

    commonPanels.timeseries(
      title='Overall CPU Utilisation',
      description='This panel shows historical utilisation as an average across all pods in this namespace.  It only accounts for currently deployed pods',
      height='',
      nullPointMode='connected',
      format='percent',
      query=|||
        sum (rate (container_cpu_usage_seconds_total{namespace="$namespace"}[$__interval]))
          by (namespace) * 1000 / sum(avg_over_time(container_spec_cpu_shares{namespace="$namespace"}[$__interval])) by (namespace) * 100
      |||,
      legendFormat='% cpu',
      intervalFactor=1,
      max="110",
    ),

  graphOverallRAM()::

    commonPanels.timeseries(
      title='Overall RAM Utilisation',
      description='This panel shows historical utilisation as an average across all pods in this namespace.  It only accounts for currently deployed pods',
      height='',
      nullPointMode='connected',
      format='percent',
      query=|||
        sum (container_memory_working_set_bytes{namespace="$namespace"}) by (namespace) /
          sum(container_spec_memory_limit_bytes{namespace="$namespace"}) by (namespace) * 100
      |||,
      legendFormat='% ram',
      intervalFactor=1,
      max="110",
    ),

  graphNetworkIO()::

    commonPanels.timeseries(
      title='Network IO',
      description='Traffic in and out of this namespace, as a sum of the pods within it',
      decimals=2,
      height='',
      nullPointMode='connected',
      fill=1,
      format='percent',
      query=|||
        sum (rate (container_network_receive_bytes_total{namespace="$namespace"}[$__interval])) by (namespace)
      |||,
      legendFormat='<- in',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          - sum (rate (container_network_transmit_bytes_total{namespace="$namespace"}[$__interval])) by (namespace)
        |||,
        legendFormat='-> out',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'Bps',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

  graphDiskIO()::

    commonPanels.timeseries(
      title='Disk IO',
      description='Disk reads and writes for the namespace, as a sum of the pods within it',
      decimals=2,
      height='',
      nullPointMode='connected',
      fill=1,
      format='percent',
      query=|||
        sum (rate (container_fs_writes_bytes_total{namespace="$namespace"}[$__interval])) by (namespace)
      |||,
      legendFormat='<- write',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          - sum (rate (container_fs_reads_bytes_total{namespace="$namespace"}[$__interval])) by (namespace)
        |||,
        legendFormat='-> read',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'Bps',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

  tableContainerCost()::

    commonPanels.table(
      title='Container cost and utilisation analysis',
      styles=[
        {
          alias: 'Container',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(50, 172, 45, 0.97)',
            '#c15c17',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          link: false,
          pattern: 'container',
          thresholds: [
            '30',
            '80',
          ],
          type: 'string',
          unit: 'currencyUSD',
        },
        {
          alias: 'RAM',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          pattern: 'Value #B',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #A',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: '',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Time',
          thresholds: [],
          type: 'hidden',
          unit: 'short',
        },
        {
          alias: 'Storage',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #C',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'Total',
          align: 'auto',
          colorMode: null,
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(50, 172, 45, 0.97)',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #D',
          thresholds: [],
          type: 'number',
          unit: 'currencyUSD',
        },
        {
          alias: 'CPU Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            '#bf1b00',
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #E',
          thresholds: [
            '30',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
        {
          alias: 'RAM Utilisation',
          align: 'auto',
          colorMode: 'value',
          colors: [
            'rgba(245, 54, 54, 0.9)',
            'rgba(50, 172, 45, 0.97)',
            '#ef843c',
          ],
          dateFormat: 'YYYY-MM-DD HH:mm:ss',
          decimals: 2,
          mappingType: 1,
          pattern: 'Value #F',
          thresholds: [
            '30',
            '80',
          ],
          type: 'number',
          unit: 'percent',
        },
      ],
      query=|||
        (sum(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible!="true"}/1000*
          ($costcpu - ($costcpu / 100 * $costDiscount))) by(container)  or  count(
          count(container_spec_cpu_shares{namespace="$namespace",container!="POD",pod="$pod"})
          by(container)  ) by(container) -1)+(  sum(container_spec_cpu_shares{namespace="$namespace",pod="$pod",
          container!="POD",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu) by(container)  or
          count(    count(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD"}) by(container)  ) by(container) -1)
      |||,
      intervalFactor=1,
      legendFormat='{{ pod }}',
    )
    .addTarget(
      promQuery.target(
        |||
          (sum(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible!="true"}
            /1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(container)
            or  count(    count(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD"}) by(container)  )
            by(container) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible="true"}
            /1024/1024/1024*$costpram) by(container)  or  count(    count(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD"})
            by(container)  ) by(container) -1)
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          vector(0)
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          (sum(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible!="true"}/1000
            *($costcpu - ($costcpu / 100 * $costDiscount))) by(container)  or  count(count(container_spec_cpu_shares{namespace="$namespace",container!="POD",pod="$pod"})
            by(container)  ) by(container) -1)+(  sum(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible="true"}
            /1000*$costpcpu) by(container)  or count(    count(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD"}) by(container)  )
            by(container) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD",cloud_google_com_gke_preemptible!="true"}
            /1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(container)
            or  count( count(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD"})
            by(container)  ) by(container) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD",
            cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram) by(container)  or  count(
            count(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD"}) by(container)  ) by(container) -1)
        |||,
        format='table',
        instant=true,
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(count(count(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD"}) by (container))
            by (container) * on (container) sum(irate(container_cpu_usage_seconds_total{namespace="$namespace",pod="$pod",container!="POD"}[$__interval]))
            by (container)) by (container) * 1000/sum(container_spec_cpu_shares{namespace="$namespace",pod="$pod",container!="POD"}) by (container) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ pod }}',
        intervalFactor=1,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          sum(count(count(container_memory_working_set_bytes{namespace="$namespace",pod="$pod",container!="POD"})
            by (container)) by (container) * on (container)
            sum(avg_over_time(container_memory_working_set_bytes{namespace="$namespace",pod="$pod",container!="POD"}[$__interval]))
            by (container)) by (container)/sum(container_spec_memory_limit_bytes{namespace="$namespace",pod="$pod",container!="POD"}) by (container) * 100
        |||,
        format='table',
        instant=true,
        legendFormat='{{ namespace }}',
        intervalFactor=1,
      )
    ),

  graphPodCPU()::

    commonPanels.timeseries(
      title='CPU Core Usage vs Requested',
      description='This graph attempts to show you CPU use of your application vs its requests',
      height='',
      nullPointMode='connected',
      format='percent',
      query=|||
        sum (rate (container_cpu_usage_seconds_total{namespace=~"$namespace", pod="$pod", container!="POD"}[$__interval])) by (container)
      |||,
      legendFormat='{{ container }}',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          sum(container_spec_cpu_shares{namespace=~"$namespace", pod="$pod", container!="POD"}) by (container) / 1000
        |||,
        legendFormat='{{ container }} (requested)',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'none',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

  graphPodRAM()::

    commonPanels.timeseries(
      title='RAM Usage vs Requested',
      description='This graph attempts to show you RAM use of your application vs its requests',
      height='',
      nullPointMode='connected',
      format='percent',
      query=|||
        sum (avg_over_time (container_memory_working_set_bytes{namespace="$namespace", pod="$pod", container!="POD"}[$__interval])) by (container)
      |||,
      legendFormat='{{ container }}',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          sum(container_spec_memory_limit_bytes{namespace=~"$namespace", pod="$pod", container!="POD"}) by (container)
        |||,
        legendFormat='{{ container }} (requested)',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'bytes',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

  graphPodNetworkIO()::

    commonPanels.timeseries(
      title='Network IO',
      description='Traffic in and out of this pod, as a sum of its containers',
      height='',
      nullPointMode='connected',
      fill=1,
      format='percent',
      intervalFactor=1,
      query=|||
        sum (rate (container_network_receive_bytes_total{namespace="$namespace",pod="$pod"}[$__interval])) by (pod)
      |||,
      legendFormat='<- in',
    )
    .addTarget(
      promQuery.target(
        |||
          - sum (rate (container_network_transmit_bytes_total{namespace="$namespace",pod="$pod"}[$__interval])) by (pod)
        |||,
        legendFormat='-> out',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'Bps',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

  graphPodDiskIO()::

    commonPanels.timeseries(
      title='Disk IO',
      description='Disk read writes',
      height='',
      nullPointMode='connected',
      fill=1,
      format='percent',
      query=|||
        sum (rate (container_fs_writes_bytes_total{namespace="$namespace",pod="$pod"}[$__interval])) by (pod)
      |||,
      legendFormat='<- write',
      intervalFactor=1,
    )
    .addTarget(
      promQuery.target(
        |||
          - sum (rate (container_fs_reads_bytes_total{namespace="$namespace",pod="$pod"}[$__interval])) by (pod)
        |||,
        legendFormat='-> read',
        intervalFactor=1,
      )
    ) + {
      yaxes: [
        {
          format: 'Bps',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: false,
        },
      ],
    },

}
