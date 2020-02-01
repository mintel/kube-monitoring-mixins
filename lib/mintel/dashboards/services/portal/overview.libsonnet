local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local annotations = import 'components/annotations.libsonnet';

local templates = import 'components/templates.libsonnet';
local redis = import 'components/panels/redis.libsonnet';
local django = import 'components/panels/django.libsonnet';
local celery = import 'components/panels/celery.libsonnet';
local haproxy = import 'components/panels/haproxy.libsonnet';

local panelsHeight = 200;

{
  grafanaDashboards+:: {
    'portal-overview.json':
      dashboard.new(
        '%(dashboardNamePrefix)s Portal' % $._config.mintelGrafanaK8s,
        time_from='now-3h',
        uid=($._config.mintelGrafanaK8s.grafanaDashboardIDs['portal-overview.json']),
        tags=($._config.mintelGrafanaK8s.dashboardTags) + ['portal'],
        description='A Dashboard providing an overview of the portal stack'
      )

      .addLink(link.dashboards(tags="",
        type="link",
        title="Workload",
        url="d/a164a7f0339f99e89cea5cb47e9be617/",
        includeVars=true,
        keepTime=true,
        asDropdown=false,
        targetBlank=true))

      .addAnnotation(annotations.fluxRelease)
      .addAnnotation(annotations.fluxAutoRelease)

      .addTemplate(templates.ds)
      .addTemplate(templates.namespace('portal'))
      .addTemplate(templates.app_service)
      .addTemplate(templates.celery_task_name)
      .addTemplate(templates.celery_task_state)

      .addRow(
        row.new('Overview', height=5)
        .addPanels(django.overview(serviceType='', startRow=1))
        .addPanels(haproxy.overview(serviceType='', startRow=1))
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(django.requestResponsePanels(serviceType='', startRow=1001))
      )
      .addRow(
        row.new('Resources')
        .addPanels(django.resourcePanels(serviceType='', startRow=1001))  
      )
      .addRow(
        row.new('Database', collapse=true)
        .addPanels(django.databaseOps(serviceType='', startRow=1001))  
      )
      .addRow(
        row.new('Celery', collapse=true)
        .addPanels(celery.celeryPanels(serviceType='', startRow=10001))
      )
       .addRow(
        row.new('Redis', collapse=true)
        .addPanels(redis.clientPanels(serviceType='dev-redis-cluster-portal-web', startRow=1001))
        .addPanels(redis.workload(serviceType='dev-redis-cluster-portal-web', startRow=1001))
        .addPanels(redis.data(serviceType='dev-redis-cluster-portal-web', startRow=1001))
        .addPanels(redis.replication(serviceType='dev-redis-cluster-portal-web', startRow=1001))
      )
  },
}
