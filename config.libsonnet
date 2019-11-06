{
  _config+:: {
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
  },
}
