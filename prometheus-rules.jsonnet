local kp =
  (import 'config.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      enableGKESupport: true,
    },
  };

{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) }
