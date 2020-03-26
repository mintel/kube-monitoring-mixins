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

    // If more than 50% of the PODS for a given workload are on the same node
    kubePodDistributionUnbalancedByNodePercentageThreshold: 50,
    kubePodDistributionUnbalancedByZonePercentageThreshold: 50,

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

    volumeFullPredictionSampleTime: '6h',

    // Fluentd Rules excluded types
    fluentdRulesExcludedTypes: 'type!~"^(null|rewrite_tag_filter|detect_exceptions)$"',

    // Prometheus Operator
    prometheusOperatorJobFilter: 'job="prometheus-operator"',

    // ECK Operator
    eckOperatorFilter: 'job="elastic-operator-metrics"',

    // Config for the Grafana dashboards in the Kubernetes Mixin
    mintel: {
      dashboardNamePrefix: 'Mintel / ',
      dashboardTags: ['mintel'],
    },

    nodeSelectorRegex: '"^gke.*"',

    // Cost Analysis template values
    cost_discount: '30',
    cost_cpu: '17.76',
    cost_pcpu: '5.34',
    cost_storage_ssd: '0.170',
    cost_storage_standard: '0.040',
    cost_ram: '2.38',
    cost_pram: '0.71',

  },
}
