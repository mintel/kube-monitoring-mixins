{
  grafana+: {
    dashboardDefinitions: {
      [name]: $._config.grafana.dashboards[name]
      for name in std.objectFields($._config.grafana.dashboards)
    },
  },
}
