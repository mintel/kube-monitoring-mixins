local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local tablePanel = grafana.tablePanel;
local singlestat = grafana.singlestat;

{
  grafanaDashboards+:: {
    'capacity.json':
      local cpuCoresRequests =
        singlestat.new(
          'CPU Cores Requests - Usage',
          format='percentunit',
          description='Percentage of Allocatable cpu cores already requested by pods',
          datasource='Prometheus',
          span=2,
          valueName='avg',
          valueFontSize='110%',
          colors=[
            'rgba(50, 172, 45, 0.97)',
            'rgba(237, 129, 40, 0.89)',
            'rgba(245, 54, 54, 0.9)',
          ],
          thresholds='.8, .9',
          transparent=true,
          gaugeShow=true,
          gaugeMinValue=0,
          gaugeMaxValue=1,
        )
        .addTarget(prometheus.target('sum(kube_pod_container_resource_requests_cpu_cores{%(nodeSelector)s}) / sum(kube_node_status_allocatable_cpu_cores{%(nodeSelector)s})' % $._config) { step: 240 });

      dashboard.new(
        '%(dashboardNamePrefix)sCapacity Planning' % $._config.grafanaK8s,
        time_from='now-5m',
        uid=($._config.grafanaDashboardIDs['capacity.json']),
        tags=($._config.grafanaK8s.dashboardTags) + ['capacity', 'resources'],
        description='A Dashboard to highlight current capacity usage and growth for your cluster'
      ).addRow(
        row.new('At a Glance')
        .addPanel(cpuCoresRequests)
      ),
  },
}
