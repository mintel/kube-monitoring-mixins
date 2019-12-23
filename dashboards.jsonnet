local kp =
  (import 'config.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      enableGKESupport: true,
    },
  };

{ [if std.length(std.split(name, '/')) > 1 then name else std.format('kube-prometheus/%s', name)]: kp.grafana.dashboardDefinitions[name] for name in std.objectFields(kp.grafana.dashboardDefinitions) }
