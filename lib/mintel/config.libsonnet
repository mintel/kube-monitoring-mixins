{
  _config+:: {
    local this = self,
    // Selectors are inserted between {} in Prometheus queries.
    namespaceSelector: null,
    prefixedNamespaceSelector: if self.namespaceSelector != null then self.namespaceSelector + ',' else '',

    nodeExporterSelector: 'job="node-exporter"',
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

    // Detect Increases in requests to frontend
    // THIS IS  A TEST AT anomaly detection using prometheus subqueries
    // https://medium.com/@valyala/prometheus-subqueries-in-victoriametrics-9b1492b720b3
    haProxyFrontendIncreaseRequestsRateInterval: '10m',
    haProxyFrontendIncreaseRequestsQuantileValue: '0.9',
    haProxyFrontendIncreaseRequestsQuantileRange: '24h',
    haProxyFrontendIncreaseRequestsPercentageThreshold: 500,


    // Grafana Dashboards IDs
    grafanaDashboardIDs: {
      'capacity.json': 'dbf659be3c9ce97fe0606994e8f8941bb268b5ac',
    },

    // Config for the Grafana dashboards in the Kubernetes Mixin
    grafanaK8s: {
      dashboardNamePrefix: 'MINTEL / ',
      dashboardTags: ['mintel'],

      // For links between grafana dashboards, you need to tell us if your grafana
      // servers under some non-root path.
      linkPrefix: '.',
    },

    nodeSelector: 'node=~"^gke.*"',

  },
}
