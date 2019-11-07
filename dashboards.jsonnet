local kp =
  (import 'config.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      enableGKESupport: true,
    },
  };

{ ['grafana-' + name]: kp.grafana.dashboardDefinitions[name] for name in std.objectFields(kp.grafana.dashboardDefinitions) }
