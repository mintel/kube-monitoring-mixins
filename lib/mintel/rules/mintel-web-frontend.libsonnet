{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mintel-web-frontend.rules',
        rules: [{
          expr: |||
            label_replace(
              (up) * on (pod)
                group_left(label_app_mintel_com_owner,label_app_mintel_com_pipeline_stage)
                  kube_pod_labels{label_app_mintel_com_owner=~".+", label_app_mintel_com_owner!~"sre",  label_tier="frontend", label_app_mintel_com_pipeline_stage=~".+"},
              "environment",
              "$1",
              "label_app_mintel_com_pipeline_stage",
              "(.*)"
            )
          |||,
          record: 'mintel:web_frontend:check_up',
        }],
      },
    ],
  },
}
