{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-node.rules',
        rules: [
          {
            expr: 'rate(node_network_receive_drop[1m]) + rate(node_network_transmit_drop[1m])',
            record: 'instance:node_network_drop:rate',
          }
          {
            expr: 'rate(node_network_receive_errs[1m]) + rate(node_network_transmit_errs[1m])',
            record: 'instance:node_network_errs:rate',
          }
          {
            expr: '100 - (sum by (node) (kube_pod_container_resource_requests_memory_bytes) / sum by (node) (kube_node_status_allocatable_memory_bytes)) * 100',
            record: 'node:memory_for_pod_available:percentage',
          }
          {
            expr: 'sum by (node) (kube_node_status_allocatable_memory_bytes) - sum by (node) (kube_pod_container_resource_requests_memory_bytes)',
            record: 'node:memory_for_pod_available:bytes',
          }
          {
            expr: '100 - (sum by (node) (kube_pod_container_resource_requests_cpu_cores) / sum by (node) (kube_node_status_allocatable_cpu_cores)) * 100',
            record: 'node:cpu_cores_for_pod_available:percentage',
          }
          {
            expr: 'sum by (node) (kube_node_status_allocatable_cpu_cores) - sum by (node) (kube_pod_container_resource_requests_cpu_cores)',
            record: 'node:cpu_cores_for_pod_available:cores',
          }
          {
            expr: '100 - ( (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) * 100 )',
            record: 'node:conntrack_entries_free:percentage',
          },

          // Backport removd rules from kubernetes-mixin
          {
            // Disk utilisation (seconds spent, by rate() it's bound by 1 second)
            record: ':node_disk_utilisation:avg_irate',
            expr: |||
              avg(irate(node_disk_io_time_seconds_total{%(nodeExporterSelector)s,%(diskDeviceSelector)s}[1m]))
            ||| % $._config,
          },
          {
            // Disk utilisation (seconds spent, by rate() it's bound by 1 second)
            record: 'node:node_disk_utilisation:avg_irate',
            expr: |||
              avg by (node) (
                irate(node_disk_io_time_seconds_total{%(nodeExporterSelector)s,%(diskDeviceSelector)s}[1m])
              * on (namespace, %(podLabel)s) group_left(node)
                node_namespace_pod:kube_pod_info:
              )
            ||| % $._config,
          },
          {
            // Disk saturation (seconds spent, by rate() it's bound by 1 second)
            record: ':node_disk_saturation:avg_irate',
            expr: |||
              avg(irate(node_disk_io_time_weighted_seconds_total{%(nodeExporterSelector)s,%(diskDeviceSelector)s}[1m]))
            ||| % $._config,
          },
          {
            // Disk saturation (seconds spent, by rate() it's bound by 1 second)
            record: 'node:node_disk_saturation:avg_irate',
            expr: |||
              avg by (node) (
                irate(node_disk_io_time_weighted_seconds_total{%(nodeExporterSelector)s,%(diskDeviceSelector)s}[1m])
              * on (namespace, %(podLabel)s) group_left(node)
                node_namespace_pod:kube_pod_info:
              )
            ||| % $._config,
          },
          {
            record: 'node:node_filesystem_usage:',
            expr: |||
              max by (instance, namespace, %(podLabel)s, device) ((node_filesystem_size_bytes{%(fstypeSelector)s}
              - node_filesystem_avail_bytes{%(fstypeSelector)s})
              / node_filesystem_size_bytes{%(fstypeSelector)s})
            ||| % $._config,
          },
          {
            record: 'node:node_filesystem_avail:',
            expr: |||
              max by (instance, namespace, %(podLabel)s, device) (node_filesystem_avail_bytes{%(fstypeSelector)s} / node_filesystem_size_bytes{%(fstypeSelector)s})
            ||| % $._config,
          },
          {
            record: 'node:node_inodes_total:',
            expr: |||
              max(
                max(
                  kube_pod_info{%(kubeStateMetricsSelector)s, host_ip!=""}
                ) by (node, host_ip)
                * on (host_ip) group_right (node)
                label_replace(
                  (max(node_filesystem_files{%(nodeExporterSelector)s, %(hostMountpointSelector)s}) by (instance)), "host_ip", "$1", "instance", "(.*):.*"
                )
              ) by (node)
            ||| % $._config,
          },
          {
            record: 'node:node_inodes_free:',
            expr: |||
              max(
                max(
                  kube_pod_info{%(kubeStateMetricsSelector)s, host_ip!=""}
                ) by (node, host_ip)
                * on (host_ip) group_right (node)
                label_replace(
                  (max(node_filesystem_files_free{%(nodeExporterSelector)s, %(hostMountpointSelector)s}) by (instance)), "host_ip", "$1", "instance", "(.*):.*"
                )
              ) by (node)
            ||| % $._config,
          },
        ],
      },
    ],
  },
}
