{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-web-frontend',
        rules: [{
          expr: 'label_replace( (up) * on (pod) group_left(label_environment) kube_pod_labels{label_vendor="mintel", label_tier="frontend"}, "environment", "$1", "label_environment", "(.*)")',
          record: 'mintel:web_frontend:check_up',
        }],
      },
    ],
  },
}
