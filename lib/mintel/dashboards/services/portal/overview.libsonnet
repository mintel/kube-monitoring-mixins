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

// Dashboard settings
local dashboardTitle = 'Portal';
local dashboardDescription = "Provides an overview of the Portal stack";
local dashboardFile = 'portal-overview.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);
local dashboardWorkloadLink = '/d/a164a7f0339f99e89cea5cb47e9be617';

local dashboardTags = ['portal'];
// End dashboard settings

{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
           ($._config.mintel + {'dashboardTitle': dashboardTitle }),
        time_from='now-3h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
      )

      .addLink(link.dashboards(tags="",
        type="link",
        title="Workload",
        url=dashboardWorkloadLink,
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
        .addPanels(django.overview())
        .addPanels(haproxy.overview(serviceSelectorKey="service", serviceSelectorValue="$service"))
      )
      .addRow(
        row.new('Request / Response')
        .addPanels(django.requestResponsePanels())
      )
      .addRow(
        row.new('Resources')
        .addPanels(django.resourcePanels())  
      )
      .addRow(
        row.new('Database', collapse=true)
        .addPanels(django.databaseOps())  
      )
      .addRow(
        row.new('Celery', collapse=true)
        .addPanels(celery.celeryPanels(serviceType='', startRow=1001))
      )
       .addRow(
        row.new('Redis', collapse=true)
        .addPanels(redis.clientPanels(serviceType='dev-redis-cluster-portal-web', startRow=1002))
        .addPanels(redis.workload(serviceType='dev-redis-cluster-portal-web', startRow=1002))
        .addPanels(redis.data(serviceType='dev-redis-cluster-portal-web', startRow=1002))
        .addPanels(redis.replication(serviceType='dev-redis-cluster-portal-web', startRow=1002))
      )
  },
}
