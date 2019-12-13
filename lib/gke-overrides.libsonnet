// Define a list of alerts to ignore
local ignore_alerts = [
  'KubeAPIErrorsHigh',
  'KubeAPILatencyHigh',
  'KubeClientErrors',
  'KubeClientCertificateExpiration',
  'KubeControllerManagerDown',
  'KubeSchedulerDown',
  'NodeNetworkReceiveErrs',
  'NodeNetworkTransmitErrs',
];

// Define a list of groups to ignore
local ignore_groups = [
  'kube-scheduler.rules',
  'kube-apiserver.rules',
  'prometheus.rules',
];

// Define a mapping of alert/recordname to expression.
// Overrides the expr field for the specifeid record name.
local expr_overrides = {};

// Define a mapping of alertname to label page:false
// It will add a label `page:false`
local page_false_critical = [

];

local set_page_false(group) =
                            group {
                              rules: std.map(
                                function(rule)
                                  if std.objectHas(rule, 'alert') then
                                    if std.objectHas(expr_overrides, rule.alert) then
                                      rule {
                                        expr: expr_overrides[rule.alert],
                                      }
                                    else
                                      rule
                                  else
                                    if std.objectHas(rule, 'record') then
                                      if std.objectHas(expr_overrides, rule.record) then
                                        rule {
                                          expr: expr_overrides[rule.record],
                                        }
                                      else
                                        rule
                                    else
                                      rule,
                                group.rules
                              ),
                            },



// Define a list of grafana dashboards to ignore
local ignore_dashboards = [
  'apiserver.json',
  'controller-manager.json',
  'scheduler.json',
];

// Now perform overrides
{
  // Override rule groups
  prometheusRules+:: {
    groups: std.filter(
      function(group)
        std.count(ignore_groups, group.name) == 0,
      super.groups
    ),
  },

  // Override alerts
  prometheusAlerts+:: {
                        // Filter specific alerts out
                        groups: std.map(
                          function(group)
                            group {
                              rules: std.filter(
                                function(rule)
                                  if std.objectHas(rule, 'alert') then
                                    std.count(ignore_alerts, rule.alert) == 0
                                  else
                                    true,
                                group.rules
                              ),
                            },
                          super.groups
                        ),
                      } +
                      {
                        // Ignore entire group of rules
                        groups: std.filter(
                          function(group)
                            std.count(ignore_groups, group.name) == 0,
                          super.groups
                        ),
                      } +
                      {
                        // Override expressions (take into account both alert and records)
                        groups: std.map(
                          function(group)
                            group {
                              rules: std.map(
                                function(rule)
                                  if std.objectHas(rule, 'alert') then
                                    if std.objectHas(expr_overrides, rule.alert) then
                                      rule {
                                        expr: expr_overrides[rule.alert],
                                      }
                                    else
                                      rule
                                  else
                                    if std.objectHas(rule, 'record') then
                                      if std.objectHas(expr_overrides, rule.record) then
                                        rule {
                                          expr: expr_overrides[rule.record],
                                        }
                                      else
                                        rule
                                    else
                                      rule,
                                group.rules
                              ),
                            },
                          super.groups
                        ),
                      },
  // Override grafana dashboards
  grafana+: {
    dashboardDefinitions: {
      [name]: $._config.grafana.dashboards[name]
      for name in std.objectFields($._config.grafana.dashboards)
      if std.count(ignore_dashboards, name) == 0
    },
  },
}
