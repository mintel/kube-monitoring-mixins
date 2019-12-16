// Configurations
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

// Define a list of record rules to ignore
local ignore_records = [];

// Define a list of groups to ignore
local ignore_groups = [
  'kube-scheduler.rules',
  'kube-apiserver.rules',
  'prometheus.rules',
];

// Map of alertname to FOR override
// overrides the for field for the specified alertname
local for_overrides = {
  KubePersistentVolumeErrors: '15m',
  KubePersistentVolumeFullInFourDays: '1h',
};

// Define a list of rules to downgrade severity for
local downgrade_severity_rules = [];

// Define a list of grafana dashboards to ignore
local ignore_dashboards = [
  'apiserver.json',
  'controller-manager.json',
  'scheduler.json',
];

// Define a mapping of alert/recordname to expression.
// Overrides the expr field for the specifeid record name.
local expr_overrides = {};

// Define a mapping of alertname to label page:false
// It will add a label `page:false` else it will add a `page:true`
local page_false_critical = [
  'ContainerCombinedIoHighOverTime',
  'KubePersistentVolumeFullInFourDays',
  'MintelReducedService',
  'MintelWebServiceDown',
  'PrometheusBadConfig',
  'PrometheusRuleFailures',
  'PrometheusRemoteStorageFailures',
  'PrometheusRemoteWriteBehind',
];


// Downgrade severity for a rule
// critical -> warning , warning -> info
local downgrade_severity(group) =
  group {
    rules: std.map(
      function(rule)
        if std.objectHas(rule, 'alert') && (std.length(std.find(rule.alert, downgrade_severity_rules)) > 0) then
          if std.objectHas(rule.labels, 'severity') then
            if (rule.labels.severity == 'critical') then
              rule {
                labels+: {
                  severity: 'warning',
                },
              }
            else if (rule.labels.severity == 'warning') then
              rule {
                labels+: {
                  severity: 'info',
                },
              }
            else
              rule
          else
            rule
        else
          rule,
      group.rules
    ),
  };


// Filtering Functions
// IF is Alert and Severity is Critical set the PAGE Labels to either false or true
local set_page_label(group) =
  group {
    rules: std.map(
      function(rule)
        if std.objectHas(rule, 'alert') then
          if std.objectHas(rule.labels, 'severity') && (rule.labels.severity == 'critical') then
            if (std.length(std.find(rule.alert, page_false_critical)) > 0) then
              rule {
                labels+: {
                  page: 'false',
                },
              }
            else
              rule {
                labels+: {
                  page: 'true',
                },
              }
          else
            rule
        else
          rule,
      group.rules
    ),
  };

// filter specific rule out
local filter_out_rule(group) =
  group {
    rules: std.filter(
      function(rule)
        if std.objectHas(rule, 'alert') then
          std.count(ignore_alerts, rule.alert) == 0
        else if std.objectHas(rule, 'record') then
          std.count(ignore_records, rule.record) == 0
        else
          true,
      group.rules
    ),
  };

// Override for field for alertname
local override_for_field_for_rule(group) =
  group {
    rules: std.map(
      function(rule)
        if std.objectHas(rule, 'alert') then
          if std.objectHas(for_overrides, rule.alert) then
            rule {
              'for': for_overrides[rule.alert],
            }
          else
            rule
        else
          rule,
      group.rules
    ),
  };


// Override expressions (take into account both alert and records)
local override_expression_for_rule(group) =
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
  };


// #####################
// Now perform overrides
// #####################
{
  // Override rule groups
  prometheusRules+::
    {
      // Filter Entire groups out
      groups: std.filter(
        function(group)
          std.count(ignore_groups, group.name) == 0,
        super.groups
      ),
    } +
    {
      // Filter Single rules out
      groups: std.map(filter_out_rule, super.groups),
    } +
    {
      // Override Expressions on per rule basis
      groups: std.map(override_expression_for_rule, super.groups),
    },

  // Override alerts
  prometheusAlerts+::
    {
      // Filter Entire groups out
      groups: std.filter(
        function(group)
          std.count(ignore_groups, group.name) == 0,
        super.groups
      ),
    } +
    {
      // Filter Single rules out
      groups: std.map(filter_out_rule, super.groups),
    } +
    {
      // Override Expressions on per rule basis
      groups: std.map(override_expression_for_rule, super.groups),
    } +
    {
      // Override for field on per rule basis
      groups: std.map(override_for_field_for_rule, super.groups),
    } +
    {
      // Set Paging label on severity:critical alerts
      groups: std.map(set_page_label, super.groups),
    } +
    {
      // Downgrade severity
      groups: std.map(downgrade_severity, super.groups),
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
