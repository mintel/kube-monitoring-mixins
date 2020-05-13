local commonPanels = import 'components/panels/common.libsonnet';
local layout = import 'components/layout.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  celeryPanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([

      commonPanels.singlestat(
        title='Num Workers',
        description='Number of Celery workers up',
        query=|||
          sum(avg_over_time(celery_workers{namespace="$namespace"}[$__interval]))
        ||| % config,
        legendFormat='{{ name }}',
        intervalFactor=2,
        span=2,
      ),
      commonPanels.timeseries(
        title='Celery Events',
        yAxisLabel='Num Events',
        query=|||
          sum(
            rate(
              celery_tasks_total{namespace="$namespace"}[10m]))
          by (name, state)
        ||| % config,
        legendFormat='{{ name }} / {{ state }}',
        intervalFactor=2,
        legend_show=true,
        legend_rightSide=true,
        span=10,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),
}
