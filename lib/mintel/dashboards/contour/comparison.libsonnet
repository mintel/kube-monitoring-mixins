local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

local templates = import 'components/templates.libsonnet';
local containers = import 'components/panels/containers.libsonnet';
local haproxy = import 'components/panels/haproxy.libsonnet';
local contour = import 'components/panels/contour-envoy.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

// Dashboard settings
local dashboardTitle = 'Haproxy Contour Comparison';
local dashboardDescription = 'Dashboard to compare performances of HAProxy vs Contour Envoy';
local dashboardFile = 'haproxy-contour-comparison.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);

local dashboardTags = ['contour', 'haproxy', 'performace', 'comparison'];
// End dashboard settings

// Some Hardcoded Variables


{
  grafanaDashboards+:: {
    local haproxyResources = containers.podResourcesRow('ingress-controller', 'haproxy-ingress-.*', 'haproxy', title='Haproxy', interval='5m'),
    local envoyResources = containers.podResourcesRow('ingress-controller', 'envoy-.*', 'envoy', title='Contour Envoy', interval='5m'),
    local clusterSelector = '${namespace}_${deployment}_[0-9]+',
    local haproxyInterval = '5m',
    local envoyInterval = '5m',

    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-1h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.namespace(''))
      .addTemplate(templates.app_deployment)
      .addRow(
        row.new('Ingress Resources')
        .addPanels([haproxyResources[0], envoyResources[0], haproxyResources[1], envoyResources[1]])
      )
      .addRow(
        row.new('Workload Resources')
        .addPanels(containers.podResourcesRow('$namespace', '$deployment.*', '.*', title='$deployment', interval=haproxyInterval))
      )
      .addRow(
        row.new('Haproxy Performances')
        .addPanel(
          commonPanels.timeseries(
            title='HAProxy Responses /s',
            description='Haproxy Total Responses',
            yAxisLabel='Num Responses/s',
            format='reqps',
            span=6,
            legend_show=true,
            height=300,
            query=|||
              sum(
                rate(
                  haproxy_backend_http_responses_total{backend=~"$namespace-.*$deployment.*"}[%(interval)s]
                )
              ) by (code)
            ||| % { interval: haproxyInterval },
            legendFormat='{{ code }}',
            intervalFactor=2,
          )
        )
        .addPanel(haproxy.latencyTimeseries(serviceSelectorKey='service', serviceSelectorValue='$deployment', interval=haproxyInterval, span=6))
      )
      .addRow(
        row.new('Envoy Performances')
        .addPanels([
          contour.clusterResponsesTimeseries(clusterSelector, interval=envoyInterval, span=6),
          contour.clusterLatencyTimeseries(clusterSelector, interval=envoyInterval, span=6),
        ])
      ),
  },
}
