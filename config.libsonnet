// Core configuration (mostly from upstream)
(import 'grafana/grafana.libsonnet') +
(import 'node-mixin/mixin.libsonnet') +
(import 'prometheus-operator/prometheus-operator.libsonnet') +
//(import 'prometheus-adapter/prometheus-adapter.libsonnet') +
(import 'kube-prometheus/alerts/alerts.libsonnet') +
(import 'kube-prometheus/rules/rules.libsonnet') +
(import 'kubernetes-mixin/mixin.libsonnet') +
(import 'prometheus/mixin.libsonnet') +
(import 'promtail-mixin/mixin.libsonnet') +
(import 'lib/prometheus.libsonnet') +
(import 'lib/grafana.libsonnet') +
(import 'lib/mintel/mixins.libsonnet') +

// Enable GKE Overrides - to be applied against core-configuration
(import 'lib/gke-overrides.libsonnet') +
{
  _config+:: {
    namespace:: error 'namespace is required',

    cadvisorSelector: 'job="kubelet"',
    kubeletSelector: 'job="kubelet"',
    kubeStateMetricsSelector: 'job="monitoring/kube-state-metrics"',
    nodeExporterSelector: 'job="monitoring/node-exporter"',
    notKubeDnsSelector: 'job!="kube-dns"',
    kubeSchedulerSelector: 'job="kube-scheduler"',
    kubeControllerManagerSelector: 'job="kube-controller-manager"',
    kubeApiserverSelector: 'job="apiserver"',
    coreDNSSelector: 'job="kube-system/kube-dns"',
    externalDnsJobSelector: 'job="kube-system/external-dns"',
    podLabel: 'pod',

    // Select the device for Io Container reads/writes metrics
    containerIoDiskDeviceSelector: 'device="/dev/sda"',
    // Select the Interval for Rate function for Io Container reads/writes metrics
    containerIoDiskDeviceRateInterval: '5m',
    // ContainerIoBytes thresholds
    containerIoBytesValueThreshold: '20000000',
    containerIoBytesTimeThreshold: '12h',
    // Criticality of containerIo Alerts
    containerIoCriticality: 'critical',

    // CPU Throttling settings
    cpuThrottlingPercent: 60,
    // Ignore containers we do not manage
    cpuThrottlingSelector: 'container!~"ingress-default-backend|redis-exporter|metadata-proxy|autoscaler|metrics-server(-nanny)?"',

    // This list of filesystem is referenced in various expressions.
    fstypes: ['ext4'],
    fstypeSelector: 'fstype="ext4", mountpoint="/mnt/stateful_partition"',
    hostMountpointSelector: 'mountpoint="/mnt/stateful_partition"',

    // This list of disk device names is referenced in various expressions.
    diskDevices: ['sda'],
    diskDeviceSelector: 'device=~"sda"',

    /// Same, but for node-mixin
    fsSelector: self.fstypeSelector,

    alertmanagerSelector: 'job="monitoring/alertmanager",alertmanager="main"',
    prometheusSelector: 'job="prometheus-' + $._config.prometheus.name + '",namespace="' + $._config.namespace + '"',
    prometheusName: '{{$labels.namespace}}/{{$labels.pod}}',
    prometheusOperatorSelector: 'job="monitoring/prometheus-operator"',


    // If more than 51% of the PODS for a given workload are on the same node
    kubePodDistributionUnbalancedPercentageThreshold: 51,

    // We alert when the aggregate (CPU, Memory) quota for all namespaces is
    // greater than the amount of the resources in the cluster.  We do however
    // allow you to overcommit if you wish.
    namespaceOvercommitFactor: 1.5,

    // BaseURL for mintel-specific runbooks.
    runBookBaseURL: 'https://gitlab.com/mintel/satoshi/docs/blob/master/runbooks',

    // The following jobs will be monitored for their ABSENCE , if they disappear an alert will be raised
    // They will alert as `critical` so be careful what you add here
    jobs: {
      Kubelet: $._config.kubeletSelector,
      KubeScheduler: $._config.kubeSchedulerSelector,
      KubeControllerManager: $._config.kubeControllerManagerSelector,
      KubeAPI: $._config.kubeApiserverSelector,
      KubeStateMetrics: $._config.kubeStateMetricsSelector,
      NodeExporter: $._config.nodeExporterSelector,
      Alertmanager: $._config.alertmanagerSelector,
      Prometheus: $._config.prometheusSelector,
      PrometheusOperator: $._config.prometheusOperatorSelector,
      CoreDNS: $._config.coreDNSSelector,
      HaproxyIngress: 'job="haproxy-exporter"',
      // externalDns: $._config.externalDnsJobSelector,
    },

    alertmanager+:: {
      name: 'main',
    },


    prometheus+:: {
      name: 'k8s',
      namespaces: ['kube-system', $._config.namespace],
      rules: $.prometheusRules + $.prometheusAlerts,
    },
    grafana+:: {
      dashboards: $.grafanaDashboards,
    },
  },
}
