local commonPanels = import 'components/panels/common.libsonnet';
{

  alertsFiring(span=2)::

    commonPanels.singlestat(
      title='Alerts Firing',
      span=span,
      height=100,
      instant=true,
      thresholds="1,3",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(ALERTS{alertstate="firing",alertname!~"DeadMansSwitch|Watchdog"})
      |||,
    ),

  alertsPending(span=2)::

    commonPanels.singlestat(
      title='Alerts Pending',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(ALERTS{alertstate="pending",alertname!~"DeadMansSwitch|Watchdog"})
      |||,
    ),

  targetDownFiring(span=2)::

    commonPanels.singlestat(
      title='TargetDown is Firing',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorBackground=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: '1',
          op: '=',
          text: 'ALERT',
        },
        {
          value: '2',
          op: '=',
          text: 'OK',
        },
      ],
      query=|||
          1 + (absent(sum(ALERTS{alertname="TargetDown",alertstate="firing"})) or vector(0))
      |||,
    ),

  nodeBadConditions(span=2)::

    commonPanels.singlestat(
      title='Nodes with Bad Conditions',
      span=span,
      height=100,
      instant=true,
      thresholds="1,2",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(sum by (node)(kube_node_status_condition{condition!="Ready", status="true"}) > 0) OR on() vector(0)
      |||,
    ),

  alertDetails(span=12)::

    commonPanels.table(
      title='Alert Details',
      description='This table shows the current alerts either in a pending or firing state',
      styles=[
          {
            alias: 'alertname',
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
            pattern: 'alertname',
            thresholds: [],
            type: 'text',
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
           pattern: 'Value',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: '__name__',
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
           pattern: '__name__',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'app_mintel_com_owner',
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
           pattern: 'app_mintel_com_owner',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'container',
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
           pattern: 'container',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'created_by_kind',
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
           pattern: 'created_by_kind',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'created by',
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
           pattern: 'created_by_name',
           thresholds: [],
           type: 'text',
           unit: 'short',
         },
         {
           alias: 'cronjob',
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
           pattern: 'cronjob',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'deployment',
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
           pattern: 'deployment',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'endpoint',
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
           pattern: 'endpoint',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'instance',
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
           pattern: 'instance',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'job',
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
           pattern: 'job',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'method',
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
           pattern: 'method',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'namespace',
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
           alias: 'node',
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
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'page',
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
           pattern: 'page',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'pod',
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
           pattern: 'pod',
           thresholds: [],
           type: 'text',
           unit: 'short',
         },
         {
           alias: 'service',
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
           pattern: 'service',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
         {
           alias: 'severity',
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
           pattern: 'severity',
           thresholds: [],
           type: 'text',
           unit: 'short',
         },
         {
           alias: 'success',
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
           pattern: 'success',
           thresholds: [],
           type: 'hidden',
           unit: 'short',
         },
      ],
      query=|||
        ALERTS{alertname!~"DeadMansSwitch|Watchdog"}
      |||,
      intervalFactor=1,
      legendFormat='',
      span=span,
    ),

  crashloopingPods(span=2)::

    commonPanels.singlestat(
      title='Crashlooping Pods',
      span=span,
      height=100,
      instant=true,
      thresholds="1,2",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(increase(kube_pod_container_status_restarts_total[1h]) > 5)
      |||,
    ),

  statefulReplicaMismatch(span=2)::

    commonPanels.singlestat(
      title='StatefulSet replica Mismatch',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(ALERTS{alertname="KubeStatefulSetReplicasMismatch"})
      |||,
    ),

  deploymentReplicaMismatch(span=2)::

    commonPanels.singlestat(
      title='Deployment replicas not updated',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(ALERTS{alertname="DeploymentReplicasNotUpdated"})
      |||,
    ),

  daemonsetRolloutStuck(span=2)::

    commonPanels.singlestat(
      title='DaemonSet Rollout Stuck',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(ALERTS{alertname="DaemonSetRolloutStuck"})
      |||,
    ),

  daemonsetNotScheduled(span=2)::

    commonPanels.singlestat(
      title='DaemonSet Not Scheduled',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          count(ALERTS{alertname="K8SDaemonSetsNotScheduled"})
      |||,
    ),

  oomKilledPods(span=2)::

    commonPanels.singlestat(
      title='OOM Killed Pods',
      span=span,
      height=100,
      instant=true,
      thresholds="1,2",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      datasource="Elasticsearch-events",
      query=|||
          OOMKilling
      |||,
      sparklineShow=false,
    ),

  nodeNotReady(span=2)::

    commonPanels.singlestat(
      title='Node Not Ready',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(kube_node_status_condition{condition="Ready",status!="true"})
      |||,
    ),

  nodeDiskPressure(span=2)::

    commonPanels.singlestat(
      title='Node Disk Pressure',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(kube_node_status_condition{condition="DiskPressure",status="true"})
      |||,
    ),

  nodeMemoryPressure(span=2)::

    commonPanels.singlestat(
      title='Node Memory Pressure',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(kube_node_status_condition{condition="MemoryPressure",status="true"})
      |||,
    ),

  nodesUnschedulable(span=2)::

    commonPanels.singlestat(
      title='Nodes Unschedulable',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(kube_node_spec_unschedulable)
      |||,
    ),

  nodesLowCpuCount(span=2)::

    commonPanels.singlestat(
      title='Nodes With low Cpu Cores for new pods',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(ALERTS{alertstate="firing",alertname="NodeCpuAvailableForPodsLow"})
      |||,
    ),

  nodesLowMemoryCount(span=2)::

    commonPanels.singlestat(
      title='Nodes With low Memory for new pods',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        'rgba(50, 172, 45, 0.97)',
        'rgba(237, 129, 40, 0.89)',
        'rgba(245, 54, 54, 0.9)',
      ],
      valueMaps=[
        {
          value: 'null',
          op: '=',
          text: '0',
        },
      ],
      query=|||
          sum(ALERTS{alertstate="firing",alertname="NodeMemoryAvailableForPodsLow"})
      |||,
    ),

}
