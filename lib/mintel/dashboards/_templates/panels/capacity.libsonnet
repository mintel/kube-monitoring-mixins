local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local common = import 'common.libsonnet';

{

  panels+:: {
    cpuCoresRequestsGauge: common.gauge {
      title: 'CPU Cores Requests - Usage',
      description: 'Percentage of Allocatable cpu cores already requested by pods',
    }.addTarget(
      prometheus.target('sum(kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s}) / sum(kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s})' % $._config, instant=true) {
        step: 240,
      }
    ),


    cpuCoresRequestsDotPanel: common.statusDotPanel {
      title: 'CPU requested per node',
      description: 'Requested cpu per Node',
    }.addTarget(prometheus.target('100 * (sum by (node) (kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s}) / sum by (node) (kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s}))' % $._config, instant=true)),

    cpuIdleGraphPanel: common.graphPanel {
      title: 'Idle CPU',
      description: 'IDLE cpu in the cluster',
      span: 4,
      yaxes: [
        {
          format: 'percent',
          label: 'cpu usage',
          logBase: 1,
          min: 0,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('avg(rate(node_cpu_seconds_total{mode="idle"}[2m]) * on(instance) group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s} * 100) by (mode)' % $._config, intervalFactor=10, legendFormat='% Idle') {
      step: 50,
    }),

    memoryFreeGraphPanel: common.graphPanel {
      title: 'Memory Free',
      description: 'Memory Usage in the Cluster',
      span: 4,
      yaxes: [
        {
          format: 'percent',
          label: 'memory usage',
          logBase: 1,
          min: 0,
          show: true,
        },
        {
          format: 'short',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('100 * (1 - ((sum(node_memory_MemTotal_bytes) - sum(node_memory_MemAvailable_bytes)) / sum(node_memory_MemTotal_bytes)))' % $._config, intervalFactor=10, legendFormat='% Free') {
      step: 50,
    }),

    memoryRequestsGauge: common.gauge {
      title: 'Memory Requests - Usage',
      description: 'Percentage of Allocatable Memory already requested by pods',
    }.addTarget(prometheus.target('sum(kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) / sum(kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s})' % $._config, instant=true) { step: 240 }),

    memoryRequestsDotPanel: common.statusDotPanel {
      title: 'Memory requested per node',
      description: 'Requested memory per Node',
    }.addTarget(prometheus.target('100 * (sum by (node) (kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) / sum by (node) (kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s}))' % $._config, instant=true)),

    ephemeralDiskUsageGauge: common.gauge {
      title: 'Ephemeral Disk - Usage',
      description: 'Percentage of ephemeral disk in use',
    }.addTarget(prometheus.target('1 - sum(node:node_filesystem_avail: - node:node_filesystem_usage:) / sum(node:node_filesystem_avail:)' % $._config, instant=true) { step: 240 }),

    ephemeralDiskUsageDotPanel: common.statusDotPanel {
      title: 'Ephemeral Disk usage per node',
      description: 'Percentage of ephemeral disk usage per node',
    }.addTarget(prometheus.target('100 * avg(node:node_filesystem_usage: * on(instance) group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s}) by (nodename)' % $._config, instant=true)),

    ephemeralDiskIOPanel: common.graphPanel {
      title: 'Ephemeral Disk IO',
      description: 'Ephemeral Disk IO',
      span: 4,
      legend: {
        alignAsTable: false,
        avg: false,
        current: false,
        hideEmpty: false,
        hideZero: false,
        max: false,
        min: false,
        rightSide: false,
        show: true,
        total: false,
        values: false,
      },
      seriesOverrides: [
        {
          alias: 'read',
          yaxis: 1,
        },
        {
          alias: 'io time',
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
          format: 's',
          logBase: 1,
          show: true,
        },
      ],
    }.addTarget(prometheus.target('sum(rate(node_disk_read_bytes_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='read') { step: 20 })
                          .addTarget(prometheus.target('sum(rate(node_disk_written_bytes_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='written') { step: 20 })
                          .addTarget(prometheus.target('sum(rate(node_disk_io_time_seconds_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='io time') { step: 20 }),


    numberOfNodes: common.singlestat {
      title: 'Number of Nodes',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_info{node=~%(nodeSelectorRegex)s})' % $._config,
      )
    ),

    numberOfNodePools: common.singlestat {
      title: 'Number of NodePools',
    }.addTarget(
      grafana.prometheus.target(
        'count (count by (label_cloud_google_com_gke_nodepool) (kube_node_labels{node=~%(nodeSelectorRegex)s}))' % $._config,
      )
    ),

    podsAvailableSlots: common.singlestat {
      title: 'Pods Allocatables Slots',
    }.addTarget(
      grafana.prometheus.target(
        'sum (kube_node_status_allocatable_pods{node=~%(nodeSelectorRegex)s}) - sum(kube_pod_status_phase{phase="Running"})' % $._config,
      )
    ),

    nodesWithDiskPressure: common.singlestat {
      title: 'Nodes Disk Pressures',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_status_condition{condition="DiskPressure", node=~%(nodeSelectorRegex)s, status="true"})' % $._config,
      )
    ),

    nodesNotReady: common.singlestat {
      title: 'Nodes Not Ready',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_status_condition{condition="Ready", node=~%(nodeSelectorRegex)s, status="false"})' % $._config,
      )
    ),

    nodesUnavailable: common.singlestat {
      title: 'Nodes Unavailable',
      colorBackground: true,
      thresholds: '1',
    }.addTarget(
      grafana.prometheus.target(
        'sum(kube_node_spec_unschedulable{node=~%(nodeSelectorRegex)s})' % $._config,
      )
    ),

  },
}
