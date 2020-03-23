local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{

      cpuUtilisation()::

        commonPanels.gauge(
          title='CPU Utilisation',
          description='This gauge shows the current CPU use vs CPU available',
          query=|||
            sum (rate (container_cpu_usage_seconds_total{id!="/",service="kubelet"}[1m]))
              /
              sum (machine_cpu_cores{service="kubelet"}) * 100
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

        tableNodeUtilisation()::

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

}