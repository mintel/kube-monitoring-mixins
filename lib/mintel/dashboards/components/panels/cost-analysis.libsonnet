local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{

      cpuUtilisation(span=2)::

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
          height=180,
          interval='',
          span=span,
          thresholds='30, 80',
          valueFontSize='80%',
          valueName='current',
        ),

      cpuRequests(span=2)::

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
          height=180,
          interval='',
          span=span,
          thresholds='30, 80',
          valueFontSize='80%',
          valueName='current',
        ),

      cpuCost(span=2)::

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
          height=180,
          interval= "10s",
          legendFormat= " {{ node }}",
          span=span,
        ),

        storageCost(span=2)::

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
            height=180,
            interval= "10s",
            legendFormat= " {{ node }}",
            span=span,
          ),

        tableNode(span=4)::

          commonPanels.table(
            title='Cluster Node Utilisation by CPU and RAM requests',
            description='This table shows the comparison of CPU and RAM requests by applications, vs the capacity of the node',
            span=span,
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
            columns=[
                        {
                          "expr": "(sum(kube_pod_container_resource_requests_memory_bytes) by (node) / sum(kube_node_status_allocatable_memory_bytes) by (node)) * 100",
                          "format": "table",
                          "hide": false,
                          "instant": true,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "{{ node }}",
                          "refId": "A"
                        },
                        {
                          "expr": "(sum(kube_pod_container_resource_requests_cpu_cores) by (node) / sum(kube_node_status_allocatable_cpu_cores) by (node)) * 100",
                          "format": "table",
                          "instant": true,
                          "intervalFactor": 1,
                          "legendFormat": "{{ node }}",
                          "refId": "B"
                        }
                    ],
          ),

      ramUtilisation(span=2)::

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
          height=180,
          interval='',
          span=span,
          thresholds='30, 80',
          valueFontSize='80%',
          valueName='current',
        ),

      ramRequests(span=2)::

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
          height=180,
          interval='',
          span=span,
          thresholds='30, 80',
          valueFontSize='80%',
          valueName='current',
        ),

      ramCost(span=2)::

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
          height=180,
          interval= "10s",
          legendFormat= " {{ node }}",
          span=span,
        ),

      totalCost(span=2)::

        commonPanels.singlestat(
          title='Total Cost',
          span=span,
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

      tableNamespace(span=4)::

        commonPanels.table(
          title='Namespace cost and utilisation analysis',
          span=span,
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
          columns=[
                  {
                    "expr": "(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_cpu_cores:sum) * ($costcpu - ($costcpu / 100 * $costDiscount)) \n)\n\n+\n\n(\n  sum(container_spec_cpu_shares{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(namespace)\n  or\n  count(\n    count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n)",
                    "format": "table",
                    "hide": false,
                    "instant": true,
                    "interval": "",
                    "intervalFactor": 1,
                    "legendFormat": "{{ namespace }}",
                    "refId": "A"
                  },
                  {
                    "expr": "(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))\n)\n\n+\n\n(\n  sum(container_spec_memory_limit_bytes{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(namespace)\n  or\n  count(\n    count(container_spec_memory_limit_bytes{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n)",
                    "format": "table",
                    "instant": true,
                    "intervalFactor": 1,
                    "legendFormat": "{{ namespace }}",
                    "refId": "B"
                  },
                  {
                    "expr": "sum (\n  sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace) / 1024 / 1024 /1024 * $costStorageSSD\nor sum (\n    sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace) / 1024 / 1024 /1024 * $costStorageStandard\nor\n    count(\n      count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1",
                    "format": "table",
                    "instant": true,
                    "intervalFactor": 1,
                    "legendFormat": "{{ namespace }}",
                    "refId": "C"
                  },
                  {
                    "expr": "# Add the CPU\n(\n(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_cpu_cores:sum) * ($costcpu - ($costcpu / 100 * $costDiscount)) \n)\n  \n  +\n  \n  (\n    sum(container_spec_cpu_shares{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1000*$costpcpu) by(namespace)\n    or\n    count(\n      count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1\n  )\n)\n\n+ \n# Add the RAM\n(\n(\n  sum by (namespace) (namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)/1024/1024/1024*($costram- ($costram / 100 * $costDiscount))\n)\n\n  \n  +\n  \n  (\n    sum(container_spec_memory_limit_bytes{namespace!=\"\",cloud_google_com_gke_preemptible=\"true\"}/1024/1024/1024*$costpram) by(namespace)\n    or\n    count(\n      count(container_spec_memory_limit_bytes{namespace!=\"\"}) by(namespace)\n    ) by(namespace) -1\n  )\n)\n\n+\n# Add the storage\n(\n\n  sum (\n    sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n  ) by (namespace) / 1024 / 1024 /1024 * $costStorageSSD\n  \n  or\n  \n  sum (\n    sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n    + on (persistentvolumeclaim, namespace) group_right(storageclass)\n    sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n  ) by (namespace) / 1024 / 1024 /1024 * $costStorageStandard\n  \n  or\n  \n  count(\n    count(container_spec_cpu_shares{namespace!=\"\"}) by(namespace)\n  ) by(namespace) -1\n\n)",
                    "format": "table",
                    "instant": true,
                    "intervalFactor": 1,
                    "refId": "D"
                  },
                  {
                    "expr": "( sum by (namespace) (rate(container_cpu_usage_seconds_total{container_name!=\"\",image!=\"\",service=\"kubelet\"}[1m]))  /  ignoring(namespace) group_left() (sum (kube_node_status_allocatable_cpu_cores)) ) * 100",
                    "format": "table",
                    "instant": true,
                    "intervalFactor": 1,
                    "legendFormat": "{{ namespace }}",
                    "refId": "E"
                  },
                  {
                    "expr": "sum(\n   count(count(container_memory_working_set_bytes{namespace!=\"\"}) by (pod_name, namespace)) by (pod_name, namespace)  \n   * on (pod_name, namespace) \n   sum(avg_over_time(container_memory_working_set_bytes{namespace!=\"\"}[1m])) by (pod_name, namespace)\n) by (namespace)\n/\nsum(container_spec_memory_limit_bytes{namespace!=\"\"}) by (namespace) * 100\n",
                    "format": "table",
                    "instant": true,
                    "intervalFactor": 1,
                    "legendFormat": "{{ namespace }}",
                    "refId": "F"
                  }
                  ],
        ),

        tablePVC(span=4)::

          commonPanels.table(
            title='Persistent Volume Claims',
            span=span,
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
            columns=[
                    {
                      "expr": "sum (\n  sum(kube_persistentvolumeclaim_info{storageclass=~\".*ssd.*|fast\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageSSD\n\nor\n\nsum (\n  sum(kube_persistentvolumeclaim_info{storageclass!~\".*ssd.*\"}) by (persistentvolumeclaim, namespace, storageclass)\n  + on (persistentvolumeclaim, namespace) group_right(storageclass)\n  sum(kube_persistentvolumeclaim_resource_requests_storage_bytes) by (persistentvolumeclaim, namespace)\n) by (namespace,persistentvolumeclaim,storageclass) / 1024 / 1024 /1024 * $costStorageStandard\n",
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

}