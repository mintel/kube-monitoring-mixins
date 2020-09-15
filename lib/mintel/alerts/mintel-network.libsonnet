{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'mintel-network.alerts',
        rules: [
                 {
                   alert: 'PrometheusOutboundNetworkTrafficAnomalyDetected',
                   annotations: {
                     description: 'Prometheus Pod {{ $labels.pod }} Outbound traffic Anomaly detected',
                     runbook_url: '%(runBookBaseURL)s/core/NetworkTrafficAnomalyDetected.md' % $._config,
                     summary: 'Prometheus Outbound Network Traffic Anomaly Detected',
                   },
                   expr: |||
                     abs(
                       sum by (pod) (
                         ( 
                           rate(container_network_transmit_bytes_total{namespace="monitoring", pod=~"prometheus-k8s-."}[15m]) - 
                           avg_over_time(rate(container_network_transmit_bytes_total{namespace="monitoring", pod=~"prometheus-k8s-."}[15m])[1w:5m])
                         ) 
                         / stddev_over_time(rate(container_network_transmit_bytes_total{namespace="monitoring", pod=~"prometheus-k8s-."}[15m])[1w:5m]) 
                       )
                     ) > 5
                   |||,
                   'for': std.format('%s', alert.interval),
                   labels: {
                     severity: std.format('%s', alert.severity),
                   },
                 }
                 for alert in [{ severity: 'warning', interval: '10m' }, { severity: 'critical', interval: '20m' }]
               ] +
               [
                 {
                   alert: 'PromtailOutboundNetworkTrafficAnomalyDetected',
                   annotations: {
                     description: 'Promtail Pod {{ $labels.pod }} Outbound traffic Anomaly detected',
                     runbook_url: '%(runBookBaseURL)s/core/NetworkTrafficAnomalyDetected.md' % $._config,
                     summary: 'Promtail Outbound Network Traffic Anomaly Detected',
                   },
                   expr: |||
                     abs(
                       sum by (pod) (
                         ( 
                           rate(promtail_sent_bytes_total{pod=~"promtail-.*"}[15m]) - 
                           avg_over_time(rate(promtail_sent_bytes_total{pod=~"promtail-.*"}[15m])[1w:5m])
                         ) 
                         / stddev_over_time(rate(promtail_sent_bytes_total{pod=~"promtail-.*"}[15m])[1w:5m]) 
                       )
                     ) > 8
                   |||,
                   'for': std.format('%s', alert.interval),
                   labels: {
                     severity: std.format('%s', alert.severity),
                   },
                 }
                 for alert in [{ severity: 'warning', interval: '10m' }, { severity: 'critical', interval: '20m' }]
               ] +
               [
                 {
                   alert: alert.alertname,
                   annotations: {
                     description: 'Google Nat Gateway {{ $labels.nat_gateway_name }} traffic Anomaly detected',
                     runbook_url: '%(runBookBaseURL)s/core/NetworkTrafficAnomalyDetected.md' % $._config,
                     summary: 'Google Nat Gateway Network Traffic Anomaly Detected',
                   },
                   expr: |||
                     sum by (nat_gateway_name) (
                       abs(
                         (
                           rate(%(metricname)s{}[15m]) -
                           avg_over_time(rate(%(metricname)s{}[15m])[1w:5m])
                         )
                         / stddev_over_time(rate(%(metricname)s{}[15m])[1w:5m])
                       ) > 0
                     ) > %(threshold)s
                   ||| % alert,
                   'for': std.format('%s', alert.interval),
                   labels: {
                     severity: std.format('%s', alert.severity),
                   },
                 }
                 for alert in [
                   { alertname: 'GoogleNatGatewayOutboundNetworkAnomalyDetection', metricname: 'stackdriver_gce_instance_compute_googleapis_com_nat_sent_bytes_count', severity: 'warning', interval: '60m', threshold: 20 },
                   { alertname: 'GoogleNatGatewayOutboundNetworkAnomalyDetection', metricname: 'stackdriver_gce_instance_compute_googleapis_com_nat_sent_bytes_count', severity: 'critical', interval: '90m', threshold: 20 },
                   { alertname: 'GoogleNatGatewayInboundNetworkAnomalyDetection', metricname: 'stackdriver_gce_instance_compute_googleapis_com_nat_received_bytes_count', severity: 'warning', interval: '60m', threshold: 20 },
                   { alertname: 'GoogleNatGatewayInboundNetworkAnomalyDetection', metricname: 'stackdriver_gce_instance_compute_googleapis_com_nat_received_bytes_count', severity: 'critical', interval: '90m', threshold: 20 },
                 ]
               ] +
               [],
      },
    ],
  },
}
