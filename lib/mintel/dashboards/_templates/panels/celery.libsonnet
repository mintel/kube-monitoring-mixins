local commonPanels = import '_templates/panels/common.libsonnet';
local layout = import '_templates/utils/layout.libsonnet';
local promQuery = import '_templates/utils/prom_query.libsonnet';
local seriesOverrides = import '_templates/utils/series_overrides.libsonnet';
{
  celeryPanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([

      commonPanels.timeseries(
        title='Num Workers',
        yAxisLabel='Workers',
        query=|||
          sum(avg_over_time(celery_workers{namespace=~"^$namespace$"}[5m]))
        ||| % config,
        legendFormat='{{ name }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Task Rate',
        yAxisLabel='Tasks',
        query=|||
          sum(
            rate(
              celery_tasks_total{namespace=~"^namespace$", name=~"^$celery_task_name$", state=~"^$celery_task_state$"}[5m]))
          by (name, state)
        ||| % config,
        legendFormat='{{ name }}/{{ state }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Runtime Rate',
        yAxisLabel='Tasks',
        query=|||
          sum(
            rate(
              celery_tasks_runtime_seconds_bucket{namespace=~"^$namespace$", name=~"^$celery_task_name$"}[5m]))
          by (le)
        ||| % config,
        legendFormat='{{ name }}/{{ state }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Latency',
        yAxisLabel='Tasks',
        query=|||
          sum(
            rate(
              celery_tasks_latency_seconds_bucket{namespace=~"^$namespace$", name=~"^$celery_task_name$"}[5m]))
          by (le)
        ||| % config,
        legendFormat='{{ le }}',
        intervalFactor=2,
      ),
    
      commonPanels.timeseries(
        title='Top 15 Tasks',
        yAxisLabel='Tasks',
        query=|||
          topk(15,
            sum(
              rate(
                celery_tasks_total{namespace=~"^$namespace$"}[5m])))
            by (name)
        ||| % config,
        legendFormat='{{ name }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=10, startRow=startRow),
}