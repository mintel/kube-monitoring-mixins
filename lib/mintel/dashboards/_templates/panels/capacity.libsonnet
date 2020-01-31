local commonPanels = import '_templates/panels/common.libsonnet';
local statusdotsPanel = commonPanels.statusdots;

local layout = import '_templates/utils/layout.libsonnet';
local promQuery = import '_templates/utils/prom_query.libsonnet';
local seriesOverrides = import '_templates/utils/series_overrides.libsonnet';
{

  cpuCoresRequests(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.gauge(
      title='CPU Cores Requests - Usage',
      description='Percentage of Allocatable cpu cores already requested by pods',
      query=|||
        sum(
          kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s}) 
            / 
          sum(kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s})
      ||| % config,
    ),

  cpuIdle(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.timeseries(
      title='Idle CPU',
      description='Idle CPU in the Cluster',
      yAxisLabel='CPU Usage',
      query=|||
        avg(
          rate(
            node_cpu_seconds_total{mode="idle"}[2m]) 
            *
             on(instance) group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s} * 100) 
        by (mode)
      ||| % config,
      legendFormat='% Idle',
    ),

  cpuCoresRequestsStatusDots(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.statusdots(
      title='CPU requested per node',
      description='Requested CPU per node',

      query=|||
        100 * (
          sum by (node) (kube_pod_container_resource_requests_cpu_cores{node=~%(nodeSelectorRegex)s})
          /
          sum by (node) (kube_node_status_allocatable_cpu_cores{node=~%(nodeSelectorRegex)s}))
      ||| % config,
    ),


  memoryFree(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.timeseries(
      title='Memory Free',
      description='Memory usage in the Cluster',
      yAxisLabel='Memory Usage',
      query=|||
        100 * (1 - ((
                      sum(node_memory_MemTotal_bytes) - sum(node_memory_MemAvailable_bytes)) 
                      /  
                      sum(node_memory_MemTotal_bytes)))
      ||| % config,
      legendFormat='% Free',
    ),

  memoryRequests(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.gauge(
      title='Memory Requests - Usage',
      description='Percentage of Allocatable Memory already requested by pods',

      query=|||
        sum(
          kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) 
          /
          sum(
            kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s})
      ||| % config,
    ),

  memoryRequestsStatusDots(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.statusdots(
      title='Memory requested per node',
      description='Requested memory per Node',

      query=|||
        100 * (
          sum by (node) (kube_pod_container_resource_requests_memory_bytes{node=~%(nodeSelectorRegex)s}) 
          / 
          sum by (node) (kube_node_status_allocatable_memory_bytes{node=~%(nodeSelectorRegex)s}))
      ||| % config,
    ),

  ephemeralDiskUsageGauge(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.gauge(
      title='Ephemeral Disk - Usage',
      description='Percentage of ephemeral disk in use',

      query=|||
        1 - sum(
          node:node_filesystem_avail: - node:node_filesystem_usage:) 
          /
          sum(node:node_filesystem_avail:)
      ||| % config,
    ),

  ephemeralDiskUsageStatusDots(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.statusdots(
      title='Ephemeral Disk usage per node',
      description='Percentage of ephemeral disk usage per node',


      query=|||
        100 * avg(
          node:node_filesystem_usage: * on(instance) 
          group_left(nodename) node_uname_info{nodename=~%(nodeSelectorRegex)s}) 
        by (nodename)
      ||| % config,
    ),

  ephemeralDiskIO(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.timeseries(
      title='Ephemeral Disk IO',
      description='Ephemeral Disk IO',

      yAxisLabel='read',
      // io time
      // bytes
      // FIXME
      query=|||
        sum(
          rate(
            node_disk_read_bytes_total{device=~"sd(a9|[b-z])"}[5m]))
      ||| % config,
      legendFormat='read',
    ),

    // FIXME: Multi-target
    //    .addTarget(prometheus.target('sum(rate(node_disk_written_bytes_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='written') { step: 20 })
    //.addTarget(prometheus.target('sum(rate(node_disk_io_time_seconds_total{device=~"sd(a9|[b-z])"}[5m]))' % $._config, intervalFactor=4, legendFormat='io time') { step: 20 }),


  numberOfNodes(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Number of Nodes',

      query=|||
        sum(
          kube_node_info{node=~%(nodeSelectorRegex)s})
      ||| % config,
    ),

  numberOfNodePools(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Number of NodePools',

      query=|||
        count (
          count by (
            label_cloud_google_com_gke_nodepool) (kube_node_labels{node=~%(nodeSelectorRegex)s}))
      ||| % config,
    ),

  podsAvailableSlots(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Pods Allocatables Slots',
      query=|||
        sum (
          kube_node_status_allocatable_pods{node=~%(nodeSelectorRegex)s}) 
          - 
           sum(kube_pod_status_phase{phase="Running"})
      ||| % config,
    ),

  nodesWithDiskPressure(nodeSelectorRegex, startRow)::
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Node Disk Pressures',
      query=|||
        sum(
          kube_node_status_condition{condition="DiskPressure", node=~%(nodeSelectorRegex)s, status="true"})
      ||| % config,
    ),


  nodesNotReady(nodeSelectorRegex, startRow)::
  // colorBackground: true,
  // thresholds: '1',
  // FIXME
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Nodes Not Ready',
      query=|||
        sum(
          kube_node_status_condition{condition="Ready", node=~%(nodeSelectorRegex)s, status="false"})
      ||| % config,
    ),

  nodesUnavailable(nodeSelectorRegex, startRow)::
  // colorBackground: true,
  // thresholds: '1',
  // FIXME
    local config = {
      nodeSelectorRegex: nodeSelectorRegex,
    };

    commonPanels.singlestat(
      title='Nodes Unavailable',
      query=|||
        sum(
          kube_node_spec_unschedulable{node=~%(nodeSelectorRegex)s})
      ||| % config,
    ),
}
