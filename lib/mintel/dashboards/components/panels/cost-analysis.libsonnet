local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
local seriesOverrides = import 'components/series_overrides.libsonnet';

{

      overviewText(content)::
        commonPanels.text(
          title='',
          content=content,
          transparent= true,
        ),

      cpuUtilisation()::

        commonPanels.gauge(
          title='CPU Utilisation',
          description='This gauge shows the current CPU use vs CPU available',
          query=|||
            sum (rate (container_cpu_usage_seconds_total{id!="/",service="kubelet"}[1m])) / sum (machine_cpu_cores{service="kubelet"}) * 100
          |||,
          colors= [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(50, 172, 45, 0.97)",
                    "#c15c17"
                  ],
          format='percent',
          gaugeMaxValue=100,
          interval='',
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
          colors= [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(50, 172, 45, 0.97)",
                    "#c15c17"
                  ],
          format='percent',
          gaugeMaxValue=100,
          interval='',
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
          format= "currencyUSD",
          interval= "10s",
          legendFormat= " {{ node }}",
        ),

        storageCost()::

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
                + sum(container_fs_limit_bytes{device=~"^/dev/[sv]d[a-z][1-9]$",id!="/"}) / 1024 / 1024 / 1024 * $costStorageSSD
            |||,
            format= "currencyUSD",
            interval= "10s",
            legendFormat= " {{ node }}",
          ),

        tableNode()::

          commonPanels.table(
            title='Cluster Node Utilisation by CPU and RAM requests',
            description='This table shows the comparison of CPU and RAM requests by applications, vs the capacity of the node',
            styles=[
                        {
                          "alias": "RAM Requests",
                          "align": "auto",
                          "colorMode": "value",
                          "colors": [
                            "rgba(50, 172, 45, 0.97)",
                            "#ef843c",
                            "rgba(245, 54, 54, 0.9) "
                          ],
                          "dateFormat": "YYYY-MM-DD HH:mm:ss",
                          "decimals": 2,
                          "mappingType": 1,
                          "pattern": "Value #A",
                          "thresholds": [
                            "50",
                            " 80"
                          ],
                          "type": "number",
                          "unit": "percent"
                        },
                        {
                          "alias": "Node",
                          "align": "auto",
                          "colorMode": null,
                          "colors": [
                            "rgba(245, 54, 54, 0.9)",
                            "rgba(237, 129, 40, 0.89)",
                            "rgba(50, 172, 45, 0.97)"
                          ],
                          "dateFormat": "YYYY-MM-DD HH:mm:ss",
                          "decimals": 2,
                          "mappingType": 1,
                          "pattern": "node",
                          "thresholds": [],
                          "type": "string",
                          "unit": "short"
                        },
                        {
                          "alias": "",
                          "align": "auto",
                          "colorMode": null,
                          "colors": [
                            "rgba(245, 54, 54, 0.9)",
                            "rgba(237, 129, 40, 0.89)",
                            "rgba(50, 172, 45, 0.97)"
                          ],
                          "dateFormat": "YYYY-MM-DD HH:mm:ss",
                          "decimals": 2,
                          "mappingType": 1,
                          "pattern": "Time",
                          "thresholds": [],
                          "type": "hidden",
                          "unit": "short"
                        },
                        {
                          "alias": "CPU Requests",
                          "align": "auto",
                          "colorMode": "value",
                          "colors": [
                            "rgba(50, 172, 45, 0.97)",
                            "#ef843c",
                            "rgba(245, 54, 54, 0.9)"
                          ],
                          "dateFormat": "YYYY-MM-DD HH:mm:ss",
                          "decimals": 2,
                          "mappingType": 1,
                          "pattern": "Value #B",
                          "thresholds": [
                            "50",
                            " 80"
                          ],
                          "type": "number",
                          "unit": "percent"
                        }
            ],
            query=|||
                    (sum(kube_pod_container_resource_requests_memory_bytes) by (node) / sum(kube_node_status_allocatable_memory_bytes) by (node)) * 100
                  |||,
            interval= '',
            intervalFactor= 1,
            legendFormat= '{{ node }}',
          )
          .addTarget(
            promQuery.target(
              |||
                (sum(kube_pod_container_resource_requests_cpu_cores) by (node) / sum(kube_node_status_allocatable_cpu_cores) by (node)) * 100
              |||,
              format='table',
              instant= 'true',
              legendFormat='{{ node }}',
              interval='',
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
          colors= [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(50, 172, 45, 0.97)",
                    "#c15c17"
                  ],
          format='percent',
          gaugeMaxValue=100,
          interval='',
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
              /
              sum(kube_node_status_allocatable_memory_bytes)
            ) * 100
          |||,
          colors= [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(50, 172, 45, 0.97)",
                    "#c15c17"
                  ],
          format='percent',
          gaugeMaxValue=100,
          interval='',
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
          format= "currencyUSD",
          interval= "10s",
          legendFormat= " {{ node }}",
        ),

      totalCost()::

        commonPanels.singlestat(
          title='Total Cost',
          query=|||
              # CPU
              sum(((sum(kube_node_status_capacity_cpu_cores) by (node) * on (node) group_left (label_cloud_google_com_gke_preemptible)
              kube_node_labels{label_cloud_google_com_gke_preemptible="true"}) * $costpcpu)
              or ((sum(kube_node_status_capacity_cpu_cores) by (node) * on (node) group_left (label_cloud_google_com_gke_preemptible)
              kube_node_labels{label_cloud_google_com_gke_preemptible!="true"}) * ($costcpu - ($costcpu / 100 * $costDiscount))))
              +
              # Storage
              sum (
              sum(kube_persistentvolumeclaim_info{storageclass=~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass)
              + on (persistentvolumeclaim, namespace) group_right(storageclass)
              sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)
              ) / 1024 / 1024 /1024 * $costStorageSSD
              +
              (sum (
              sum(kube_persistentvolumeclaim_info{storageclass!~".*ssd.*|fast"}) by (persistentvolumeclaim, namespace, storageclass)
              + on (persistentvolumeclaim, namespace) group_right(storageclass)
              sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)
              ) or on() vector(0)) / 1024 / 1024 /1024 * $costStorageStandard
              +
              sum(container_fs_limit_bytes{device=~"^/dev/[sv]d[a-z][1-9]$",id!="/"}) / 1024 / 1024 / 1024 * $costStorageSSD
              +
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
          |||,
          format= "currencyUSD",
          interval= "10s",
          legendFormat= " {{ node }}",
        ),

      tableNamespace()::

        commonPanels.table(
          title='Namespace cost and utilisation analysis',
          styles=[
                  {
                    "alias": "Namespace",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(50, 172, 45, 0.97)",
                      "#c15c17"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "link": true,
                    "linkTooltip": "View namespace cost analysis",
                    "linkUrl": "d/at-cost-analysis-namespace/cost-analysis-by-namespace?&var-namespace=$__cell",
                    "pattern": "namespace",
                    "thresholds": [
                      "30",
                      "80"
                    ],
                    "type": "string",
                    "unit": "currencyUSD"
                  },
                  {
                    "alias": "RAM",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(237, 129, 40, 0.89)",
                      "rgba(50, 172, 45, 0.97)"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "pattern": "Value #B",
                    "thresholds": [],
                    "type": "number",
                    "unit": "currencyUSD"
                  },
                  {
                    "alias": "CPU",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(237, 129, 40, 0.89)",
                      "rgba(50, 172, 45, 0.97)"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Value #A",
                    "thresholds": [],
                    "type": "number",
                    "unit": "currencyUSD"
                  },
                  {
                    "alias": "",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(237, 129, 40, 0.89)",
                      "rgba(50, 172, 45, 0.97)"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Time",
                    "thresholds": [],
                    "type": "hidden",
                    "unit": "short"
                  },
                  {
                    "alias": "Storage",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(237, 129, 40, 0.89)",
                      "rgba(50, 172, 45, 0.97)"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Value #C",
                    "thresholds": [],
                    "type": "number",
                    "unit": "currencyUSD"
                  },
                  {
                    "alias": "Total",
                    "align": "auto",
                    "colorMode": null,
                    "colors": [
                      "rgba(245, 54, 54, 0.9)",
                      "rgba(237, 129, 40, 0.89)",
                      "rgba(50, 172, 45, 0.97)"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Value #D",
                    "thresholds": [],
                    "type": "number",
                    "unit": "currencyUSD"
                  },
                  {
                    "alias": "CPU Utilisation",
                    "align": "auto",
                    "colorMode": "value",
                    "colors": [
                      "rgba(50, 172, 45, 0.97)",
                      "#ef843c",
                      "#bf1b00"
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Value #E",
                    "thresholds": [
                      "30",
                      "80"
                    ],
                    "type": "number",
                    "unit": "percent"
                  },
                  {
                    "alias": "RAM Utilisation",
                    "align": "auto",
                    "colorMode": "value",
                    "colors": [
                      "rgba(50, 172, 45, 0.97)",
                      "#ef843c ",
                      "rgba(245, 54, 54, 0.9) "
                    ],
                    "dateFormat": "YYYY-MM-DD HH:mm:ss",
                    "decimals": 2,
                    "mappingType": 1,
                    "pattern": "Value #F",
                    "thresholds": [
                      "30",
                      "80"
                    ],
                    "type": "number",
                    "unit": "percent"
                  }
          ],
          query=|||
                  (\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_cpu_cores:sum) * ($costcpu - ($costcpu / 100 * $costDiscount)) \n)\n\n+\n\n(\n  sum(container_spec_cpu_shares{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(namespace)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n)
                |||,
          interval= '',
          intervalFactor= 1,
          legendFormat= '{{ namespace }}',
        )
        .addTarget(
          promQuery.target(
            |||
              (\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))\n)\n\n+\n\n(\n  sum(container_spec_memory_limit_bytes{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(namespace)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n)
            |||,
            format='table',
            instant= 'true',
            legendFormat='{{ namespace }}',
            interval='',
            intervalFactor=1,
          )
        )
        .addTarget(
          promQuery.target(
            |||
              sum (\n  sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace) / 1024 / 1024 /1024 * $costStorageSSD\nor sum (\n    sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace) / 1024 / 1024 /1024 * $costStorageStandard\nor\n    count(\n      count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1
            |||,
            format='table',
            instant= 'true',
            legendFormat='{{ namespace }}',
            interval='',
            intervalFactor=1,
          )
        )
        .addTarget(
          promQuery.target(
            |||
              # Add the CPU\n(\n(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_cpu_cores:sum) * ($costcpu - ($costcpu / 100 * $costDiscount)) \n)\n  \n  +\n  \n  (\n    sum(container_spec_cpu_shares{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(namespace)\n    or\n    count(\n      count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1\n  )\n)\n\n+ \n# Add the RAM\n(\n(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))\n)\n\n  \n  +\n  \n  (\n    sum(container_spec_memory_limit_bytes{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(namespace)\n    or\n    count(\n      count(container_spec_memory_limit_bytes{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1\n  )\n)\n\n+\n# Add the storage\n(\n\n  sum (\n    sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n  ) by (namespace) / 1024 / 1024 /1024 * $costStorageSSD\n  \n  or\n  \n  sum (\n    sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n  ) by (namespace) / 1024 / 1024 /1024 * $costStorageStandard\n  \n  or\n  \n  count(\n    count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n\n)
            |||,
            format='table',
            instant= 'true',
            legendFormat='{{ namespace }}',
            interval='',
            intervalFactor=1,
          )
        )
        .addTarget(
          promQuery.target(
            |||
              ( sum by (namespace) (rate(container_cpu_usage_seconds_total{container_name!=\"\",image!=\"\",service=\"kubelet\"}[1m]))  /  ignoring(namespace) group_left() (sum (kube_node_status_allocatable_cpu_cores)) ) * 100
            |||,
            format='table',
            instant= 'true',
            legendFormat='{{ namespace }}',
            interval='',
            intervalFactor=1,
          )
        )
        .addTarget(
          promQuery.target(
            |||
              sum(\n   count(count(container_memory_working_set_bytes{namespace!=\"\"}) by (pod_name, namespace)) by (pod_name, namespace)  \n   * on (pod_name, namespace) \n   sum(avg_over_time(container_memory_working_set_bytes{namespace!=\"\"}[1m])) by (pod_name, namespace)\n) by (namespace)\n/\nsum(container_spec_memory_limit_bytes{namespace!=\"\"}) by (namespace) * 100\n
            |||,
            format='table',
            instant= 'true',
            legendFormat='{{ namespace }}',
            interval='',
            intervalFactor=1,
          )
        ),

        tablePVCCluster()::

          commonPanels.table(
            title='Persistent Volume Claims',
            styles=[
                    {
                      "alias": "Namespace",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "namespace",
                      "thresholds": [],
                      "type": "string",
                      "unit": "short"
                    },
                    {
                      "alias": "PVC Name",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "persistentvolumeclaim",
                      "thresholds": [],
                      "type": "number",
                      "unit": "short"
                    },
                    {
                      "alias": "Storage Class",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "storageclass",
                      "thresholds": [],
                      "type": "number",
                      "unit": "short"
                    },
                    {
                      "alias": "Cost",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Time",
                      "thresholds": [],
                      "type": "hidden",
                      "unit": "short"
                    }
            ],
          query=|||
                  sum (\n  sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageSSD\n\nor\n\nsum (\n  sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageStandard\n
                |||,
          interval= '',
          intervalFactor= 1,
          legendFormat= '{{ persistentvolumeclaim }}',
        ),

        tablePodCost()::

          commonPanels.table(
            title='Pod cost and utilisation analysis',
            styles=[
                    {
                      "alias": "Pod",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(50, 172, 45, 0.97)",
                        "#c15c17",
                        "rgba(245, 54, 54, 0.9)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "link": true,
                      "linkTooltip": "Click to drill down into pod",
                      "linkUrl": "d/at-cost-analysis-pod/cost-analysis-by-pod?&var-namespace=$namespace&var-pod=$__cell",
                      "pattern": "pod_name",
                      "thresholds": [
                        "30",
                        "80"
                      ],
                      "type": "string",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "RAM",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "pattern": "Value #B",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "CPU",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #A",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Time",
                      "thresholds": [],
                      "type": "hidden",
                      "unit": "short"
                    },
                    {
                      "alias": "Total",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #D",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "CPU Utilisation",
                      "align": "auto",
                      "colorMode": "value",
                      "colors": [
                        "rgba(50, 172, 45, 0.97)",
                        "#ef843c",
                        "#bf1b00"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #E",
                      "thresholds": [
                        "50",
                        "80"
                      ],
                      "type": "number",
                      "unit": "percent"
                    },
                    {
                      "alias": "RAM Utilisation",
                      "align": "auto",
                      "colorMode": "value",
                      "colors": [
                        "rgba(50, 172, 45, 0.97)",
                        "#c15c17",
                        "rgba(245, 54, 54, 0.9)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #F",
                      "thresholds": [
                        "50",
                        "80"
                      ],
                      "type": "number",
                      "unit": "percent"
                    },
                    {
                      "alias": "Storage - n/a",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #C",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    }
            ],
            columns=[
                    {
                      "expr": "(\n  sum(container_spec_cpu_shares{namespace=\"$namespace\",cloud_google_com_gke_preemptible!=\"true\"}/1000*($costcpu - ($costcpu / 100 * $costDiscount))) by(pod_name)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n+\n\n(\n  sum(container_spec_cpu_shares{namespace=\"$namespace\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(pod_name)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "interval": "",
                      "intervalFactor": 1,
                      "legendFormat": "{{ pod_name }}",
                      "refId": "A"
                    },
                    {
                      "expr": "(\n  sum(container_spec_memory_limit_bytes{namespace=\"$namespace\",cloud_google_com_gke_preemptible!=\"true\"}/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(pod_name)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n+\n\n(\n  sum(container_spec_memory_limit_bytes{namespace=\"$namespace\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(pod_name)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "intervalFactor": 1,
                      "legendFormat": "{{ namespace }}",
                      "refId": "B"
                    },
                    {
                      "expr": "vector(0)",
                      "format": "table",
                      "instant": true,
                      "intervalFactor": 1,
                      "legendFormat": "{{ namespace }}",
                      "refId": "C"
                    },
                    {
                      "expr": "(\n  sum(container_spec_cpu_shares{namespace=\"$namespace\",cloud_google_com_gke_preemptible!=\"true\"}/1000*($costcpu - ($costcpu / 100 * $costDiscount))) by(pod_name)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n+\n\n(\n  sum(container_spec_cpu_shares{namespace=\"$namespace\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(pod_name)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n# Now ram\n\n+ \n(\n  sum(container_spec_memory_limit_bytes{namespace=\"$namespace\",cloud_google_com_gke_preemptible!=\"true\"}/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(pod_name)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n+\n\n(\n  sum(container_spec_memory_limit_bytes{namespace=\"$namespace\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(pod_name)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace=\"$namespace\"}) by(pod_name)\n  ) by(pod_name) -1\n)\n\n",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "intervalFactor": 1,
                      "refId": "D"
                    },
                    {
                      "expr": "sum(\n   count(count(container_spec_cpu_shares{namespace=\"$namespace\"}) by (pod_name)) by (pod_name)  \n   * on (pod_name) \n   sum(irate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[1m])) by (pod_name)\n) by (pod_name) * 1000\n/\nsum(container_spec_cpu_shares{namespace=\"$namespace\"}) by (pod_name) * 100",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "intervalFactor": 1,
                      "legendFormat": "{{ pod_name }}",
                      "refId": "E"
                    },
                    {
                      "expr": "sum(\n   count(count(container_memory_working_set_bytes{namespace=\"$namespace\"}) by (pod_name)) by (pod_name)  \n   * on (pod_name) \n   sum(avg_over_time(container_memory_working_set_bytes{namespace=\"$namespace\"}[1m])) by (pod_name)\n) by (pod_name)\n/\nsum(container_spec_memory_limit_bytes{namespace=\"$namespace\"}) by (pod_name) * 100",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "intervalFactor": 1,
                      "legendFormat": "{{ namespace }}",
                      "refId": "F"
                    },
            ],
          ),

        tablePVCNamespace()::

          commonPanels.table(
            title='Persistent Volume Claims',
            styles=[
                    {
                      "alias": "Namespace",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "namespace",
                      "thresholds": [],
                      "type": "hidden",
                      "unit": "short"
                    },
                    {
                      "alias": "PVC Name",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "persistentvolumeclaim",
                      "thresholds": [],
                      "type": "number",
                      "unit": "short"
                    },
                    {
                      "alias": "Storage Class",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "storageclass",
                      "thresholds": [],
                      "type": "number",
                      "unit": "short"
                    },
                    {
                      "alias": "Cost",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Time",
                      "thresholds": [],
                      "type": "hidden",
                      "unit": "short"
                    }
            ],
            columns=[
                    {
                      "expr": "sum (\n  sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes{namespace=~\"$namespace\"}) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageSSD\n\nor\n\nsum (\n  sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes{namespace=~\"$namespace\"}) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageStandard\n",
                      "format": "table",
                      "hide": false,
                      "instant": true,
                      "interval": "",
                      "intervalFactor": 1,
                      "legendFormat": "{{ persistentvolumeclaim }}",
                      "refId": "A"
                    }
            ],
          ),

        graphOverallCPU()::

          commonPanels.timeseries(
            title='Overall CPU Utilisation',
            description='This panel shows historical utilisation as an average across all pods in this namespace.  It only accounts for currently deployed pods',
            height='',
            nullPointMode='connected',
            format='percent',
            query=|||
              sum (rate (container_cpu_usage_seconds_total{namespace="$namespace"}[1m]))
                by (namespace) * 1000 / sum(avg_over_time(container_spec_cpu_shares{namespace="$namespace"}[1m])) by (namespace) * 100
            |||,
            legendFormat= '% cpu',
            interval='',
            intervalFactor=1,
          ),

        graphOverallRAM()::

          commonPanels.timeseries(
            title='Overall RAM Utilisation',
            description='This panel shows historical utilisation as an average across all pods in this namespace.  It only accounts for currently deployed pods',
            height='',
            nullPointMode='connected',
            format='percent',
            query=|||
              sum (container_memory_working_set_bytes{namespace="$namespace"}) by (namespace)
              /
              sum(container_spec_memory_limit_bytes{namespace="$namespace"}) by (namespace) * 100
            |||,
            legendFormat= '% ram',
            interval='',
            intervalFactor=1,
          ),

        graphNetworkIO()::

          commonPanels.timeseries(
            title='Network IO',
            description='Traffic in and out of this namespace, as a sum of the pods within it',
            height='',
            nullPointMode='connected',
            format='percent',
            query=|||
              sum (container_memory_working_set_bytes{namespace="$namespace"}) by (namespace)
              /
              sum(container_spec_memory_limit_bytes{namespace="$namespace"}) by (namespace) * 100
            |||,
            legendFormat='<- in',
            interval='',
            intervalFactor=1,
          )
          .addTarget(
            promQuery.target(
              |||
                - sum (rate (container_network_transmit_bytes_total{namespace="$namespace"}[1m])) by (namespace)
              |||,
              legendFormat='-> out',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '<- in',
                yaxis: 1,
              },
              {
                alias: '-> out',
                yaxis: 2,
              },
            ],
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
            height='',
            nullPointMode='connected',
            format='percent',
            query=|||
              sum (rate (container_fs_writes_bytes_total{namespace="$namespace"}[1m])) by (namespace)
            |||,
            legendFormat='<- write',
            interval='',
            intervalFactor=1,
          )
          .addTarget(
            promQuery.target(
              |||
                - sum (rate (container_fs_reads_bytes_total{namespace="$namespace"}[1m])) by (namespace)
              |||,
              legendFormat='-> read',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '<- read',
                yaxis: 1,
              },
              {
                alias: '<- write',
                yaxis: 2,
              },
            ],
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
                      "alias": "Container",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(50, 172, 45, 0.97)",
                        "#c15c17"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "link": false,
                      "pattern": "container_name",
                      "thresholds": [
                        "30",
                        "80"
                      ],
                      "type": "string",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "RAM",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "pattern": "Value #B",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "CPU",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #A",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Time",
                      "thresholds": [],
                      "type": "hidden",
                      "unit": "short"
                    },
                    {
                      "alias": "Storage",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #C",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "Total",
                      "align": "auto",
                      "colorMode": null,
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(237, 129, 40, 0.89)",
                        "rgba(50, 172, 45, 0.97)"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #D",
                      "thresholds": [],
                      "type": "number",
                      "unit": "currencyUSD"
                    },
                    {
                      "alias": "CPU Utilisation",
                      "align": "auto",
                      "colorMode": "value",
                      "colors": [
                        "#bf1b00",
                        "rgba(50, 172, 45, 0.97)",
                        "#ef843c"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #E",
                      "thresholds": [
                        "30",
                        "80"
                      ],
                      "type": "number",
                      "unit": "percent"
                    },
                    {
                      "alias": "RAM Utilisation",
                      "align": "auto",
                      "colorMode": "value",
                      "colors": [
                        "rgba(245, 54, 54, 0.9)",
                        "rgba(50, 172, 45, 0.97)",
                        "#ef843c"
                      ],
                      "dateFormat": "YYYY-MM-DD HH:mm:ss",
                      "decimals": 2,
                      "mappingType": 1,
                      "pattern": "Value #F",
                      "thresholds": [
                        "30",
                        "80"
                      ],
                      "type": "number",
                      "unit": "percent"
                    }
            ],
            query=|||
                    (  sum(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible!="true"}/1000*
                    ($costcpu - ($costcpu / 100 * $costDiscount))) by(container_name)  or  count(
                    count(container_spec_cpu_shares{namespace="$namespace",container_name!="POD",pod_name="$pod"})
                    by(container_name)  ) by(container_name) -1)+(  sum(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",
                    container_name!="POD",cloud_google_com_gke_preemptible="true"}/1000*$costpcpu) by(container_name)  or
                    count(    count(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by(container_name)  ) by(container_name) -1)
                  |||,
            interval= '',
            intervalFactor= 1,
            legendFormat= '{{ pod_name }}',
          )
          .addTarget(
            promQuery.target(
              |||
                (  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible!="true"}
                /1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(container_name)
                or  count(    count(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by(container_name)  )
                by(container_name) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible="true"}
                /1024/1024/1024*$costpram) by(container_name)  or  count(    count(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"})
                by(container_name)  ) by(container_name) -1)
              |||,
              format='table',
              instant= 'true',
              legendFormat='{{ namespace }}',
              interval='',
              intervalFactor=1,
            )
          )
          .addTarget(
            promQuery.target(
              |||
                vector(0)
              |||,
              format='table',
              instant= 'true',
              legendFormat='{{ namespace }}',
              interval='',
              intervalFactor=1,
            )
          )
          .addTarget(
            promQuery.target(
              |||
                (  sum(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible!="true"}/1000
                *($costcpu - ($costcpu / 100 * $costDiscount))) by(container_name)  or  count(    count(container_spec_cpu_shares{namespace="$namespace",container_name!="POD",pod_name="$pod"})
                by(container_name)  ) by(container_name) -1)+(  sum(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible="true"}
                /1000*$costpcpu) by(container_name)  or count(    count(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by(container_name)  )
                by(container_name) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD",cloud_google_com_gke_preemptible!="true"}
                /1024/1024/1024*($costram- ($costram / 100 * $costDiscount))) by(container_name)
                or  count(    count(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"})
                by(container_name)  ) by(container_name) -1)+(  sum(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD",
                cloud_google_com_gke_preemptible="true"}/1024/1024/1024*$costpram) by(container_name)  or  count(
                count(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by(container_name)  ) by(container_name) -1)
              |||,
              format='table',
              instant= 'true',
              interval='',
              intervalFactor=1,
            )
          )
          .addTarget(
            promQuery.target(
              |||
                sum(   count(count(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by (container_name))
                by (container_name)     * on (container_name)    sum(irate(container_cpu_usage_seconds_total{namespace="$namespace",pod_name="$pod",container_name!="POD"}[1m]))
                by (container_name)) by (container_name) * 1000/sum(container_spec_cpu_shares{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by (container_name) * 100
              |||,
              format='table',
              instant= 'true',
              legendFormat='{{ pod_name }}',
              interval='',
              intervalFactor=1,
            )
          )
          .addTarget(
            promQuery.target(
              |||
                sum(   count(count(container_memory_working_set_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"})
                by (container_name)) by (container_name)     * on (container_name)
                sum(avg_over_time(container_memory_working_set_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"}[1m]))
                by (container_name)) by (container_name)/sum(container_spec_memory_limit_bytes{namespace="$namespace",pod_name="$pod",container_name!="POD"}) by (container_name) * 100
              |||,
              format='table',
              instant= 'true',
              legendFormat='{{ namespace }}',
              interval='',
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
              sum (rate (container_cpu_usage_seconds_total{namespace=~"$namespace", pod_name="$pod", container_name!="POD"}[1m])) by (container_name)
            |||,
            legendFormat='{{ container_name }}',
            interval='',
            intervalFactor=1,
          )
          .addTarget(
            promQuery.target(
              |||
                sum(container_spec_cpu_shares{namespace=~"$namespace", pod_name="$pod", container_name!="POD"}) by (container_name) / 1000
              |||,
              legendFormat='{{ container_name }} (requested)',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '{{ container_name }} (requested)',
                yaxis: 1,
              },
              {
                alias: '{{ container_name }}',
                yaxis: 2,
              },
            ],
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
              sum (avg_over_time (container_memory_working_set_bytes{namespace="$namespace", pod_name="$pod", container_name!="POD"}[1m])) by (container_name)
            |||,
            legendFormat='{{ container_name }}',
            interval='',
            intervalFactor=1,
          )
          .addTarget(
            promQuery.target(
              |||
                sum(container_spec_memory_limit_bytes{namespace=~"$namespace", pod_name="$pod", container_name!="POD"}) by (container_name)
              |||,
              legendFormat='{{ container_name }} (requested)',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '{{ container_name }} (requested)',
                yaxis: 1,
              },
              {
                alias: '{{ container_name }}',
                yaxis: 2,
              },
            ],
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
            format='percent',
            interval='',
            intervalFactor=1,
            query=|||
              sum (rate (container_network_receive_bytes_total{namespace="$namespace",pod_name="$pod"}[1m])) by (pod_name)
            |||,
            legendFormat='<- in',
          )
          .addTarget(
            promQuery.target(
              |||
                - sum (rate (container_network_transmit_bytes_total{namespace="$namespace",pod_name="$pod"}[1m])) by (pod_name)
              |||,
              legendFormat='-> out',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '-> in',
                yaxis: 1,
              },
              {
                alias: '<- out',
                yaxis: 2,
              },
            ],
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
            format='percent',
            query=|||
              sum (rate (container_fs_writes_bytes_total{namespace="$namespace",pod_name="$pod"}[1m])) by (pod_name)
            |||,
            legendFormat='<- write',
            interval='',
            intervalFactor=1,
          )
          .addTarget(
            promQuery.target(
              |||
                - sum (rate (container_fs_reads_bytes_total{namespace="$namespace",pod_name="$pod"}[1m])) by (pod_name)
              |||,
              legendFormat='-> read',
              interval='',
              intervalFactor=1,
            )
          ) + {
            seriesOverrides: [
              {
                alias: '<- read',
                yaxis: 1,
              },
              {
                alias: '<- write',
                yaxis: 2,
              },
            ],
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