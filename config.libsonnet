// Core configuration (mostly from upstream)
(import 'grafana/grafana.libsonnet') +
(import 'node-mixin/mixin.libsonnet') +
(import 'prometheus-operator/prometheus-operator.libsonnet') +
//(import 'prometheus-adapter/prometheus-adapter.libsonnet') +
(import 'kube-prometheus/alerts/alerts.libsonnet') +
(import 'kube-prometheus/rules/rules.libsonnet') +
(import 'kubernetes-mixin/mixin.libsonnet') +
(import 'prometheus/mixin.libsonnet') +
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
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    nodeExporterSelector: 'job="node-exporter"',
    notKubeDnsSelector: 'job!="kube-dns"',
    kubeSchedulerSelector: 'job="kube-scheduler"',
    kubeControllerManagerSelector: 'job="kube-controller-manager"',
    kubeApiserverSelector: 'job="apiserver"',
    coreDNSSelector: 'job="kube-dns"',
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

    alertmanagerSelector: 'job="alertmanager-' + $._config.alertmanager.name + '",namespace="' + $._config.namespace + '"',
    prometheusSelector: 'job="prometheus-' + $._config.prometheus.name + '",namespace="' + $._config.namespace + '"',
    prometheusName: '{{$labels.namespace}}/{{$labels.pod}}',
    prometheusOperatorSelector: 'job="prometheus-operator",namespace="' + $._config.namespace + '"',


    // SLI SLO Paramters
    sli_slo: {
      dev_podinfo_contour: {
        backend: {
          type: 'contour',
          namespace: 'sandbox',
          service: 'podinfo',
          port: '9898',
        },
        slo: {
          slo_target_percentage: 99,  // SLO 99%
          slo_target_time_window_days: 7,  // SLO time window over 7 Days
          error_ratio_threshold: 20,  // 1% of error to total of requests
          latency_percentile: 90,  // Consider the 95th percentile for latency
          latency_threshold_milliseconds: 4350,  // Latency for the latency percentile
        },
      },
      dev_image_service_haproxy: {
        backend: {
          type: 'haproxy',
          namespace: 'image-service',
          service: 'dev-image-service-app',
          port: '8000',
        },
        slo: {
          slo_target_percentage: 99,  // SLO 99%
          slo_target_time_window_days: 7,  // SLO time window over 7 Days
          error_ratio_threshold: 1,  // 1% of error to total of requests
          latency_percentile: 99,  // Consider the 95th percentile for latency
          latency_threshold_milliseconds: 500,  // Latency for the latency percentile
        },
      },
    },

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
