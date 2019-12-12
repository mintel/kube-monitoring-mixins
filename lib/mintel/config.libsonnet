{
  _config+:: {
    local this = self,
    // Selectors are inserted between {} in Prometheus queries.

    // Select the metrics coming from the cadvisor job
    cadvisorSelector: 'job="kubelet"',
    // Select the metrics coming from the kube-state-metrics job
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    // Select metrics coming from the Kubelet.
    kubeletSelector: 'job="kubelet"',

    // Select the device for Io Container reads/writes metrics
    containerIoDiskDeviceSelector: 'device="/dev/sda"',
    // Select the Interval for Rate function for Io Container reads/writes metrics
    containerIoDiskDeviceRateInterval: '5m',
    // ContainerIoBytes thresholds
    containerIoBytesValueThreshold: '20000000',
    containerIoBytesTimeThreshold: '12h',
    // Criticality of containerIo Alerts
    containerIoCriticality: 'critical',

    grafana_prefix: '',

    // BaseURL for mintel-specific runbooks.
    runBookBaseURL: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks',

    // We alert when the aggregate (CPU, Memory) quota for all namespaces is
    // greater than the amount of the resources in the cluster.  We do however
    // allow you to overcommit if you wish.
    // For now, until we figure out how to account for GKE Autoscaling we will multiply by 2
    namespaceOvercommitFactor: 1.5,
    quotaVsNodesOvercommitFactor: self.namespaceOvercommitFactor * 2,

    // If more than 51% of the PODS for a given workload are on the same node
    kubePodDistributionUnbalancedPercentageThreshold: 51,

    // Flux Vars
    fluxJobSelector: 'job="flux"',
    fluxDeltaIntervalMinutes: 6,
    fluxDeltaDoubleIntervalMinutes: 2 * this.fluxDeltaIntervalMinutes,
  },
}
