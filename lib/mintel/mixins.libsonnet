(import './config.libsonnet') +

(import './alerts/blackbox.libsonnet') +
(import './alerts/elasticsearch.libsonnet') +
(import './alerts/haproxy-ingress.libsonnet') +
(import './alerts/image-service.libsonnet') +
(import './alerts/kubernetes-resources.libsonnet') +
(import './alerts/mintel-containers.libsonnet') +
(import './alerts/mintel-disks.libsonnet') +
(import './alerts/mintel-node.libsonnet') +
(import './alerts/mintel-overcommit.libsonnet') +
(import './alerts/mintel-pod.libsonnet') +
(import './alerts/mintel-web-frontend.libsonnet') +

(import './rules/blackbox.libsonnet') +
(import './rules/elasticsearch.libsonnet') +
(import './rules/haproxy-ingress.libsonnet') +
(import './rules/mintel-disks.libsonnet') +
(import './rules/mintel-node.libsonnet') +
(import './rules/mintel-overcommit.libsonnet') +
(import './rules/mintel-pod.libsonnet') +
(import './rules/mintel-web-frontend.libsonnet')