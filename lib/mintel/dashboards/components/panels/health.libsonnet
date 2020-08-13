local commonPanels = import 'components/panels/common.libsonnet';
{

  alertsFiring(span=2)::

    commonPanels.singlestat(
      title='Alerts Firing',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
      colorValue=true,
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
      thresholds="3,5",
      colorValue=true,
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      query=|||
          count(sum by (node)(kube_node_status_condition{condition!="Ready", status="true"}) > 0) OR on() vector(0)
      |||,
    ),

  crashloopingPods(span=2)::

    commonPanels.singlestat(
      title='Crashlooping Pods',
      span=span,
      height=100,
      instant=true,
      thresholds="3,5",
      colorValue=true,
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
      thresholds="3,5",
      colorValue=true,
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      query=|||
          sum(kube_pod_container_status_terminated_reason{reason="OOMKilled"})
      |||,
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
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
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      query=|||
          sum(ALERTS{alertstate="firing",alertname="NodeMemoryAvailableForPodsLow"})
      |||,
    ),

}
