local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local common = import 'common.libsonnet';
{

  panels+:: {

    celeryTasksRate: common.graphPanel {
      title: 'Celery Tasks Rate',
      description: 'Celery Tasks Rate',
      span: 5,
      }
      .addTarget(prometheus.target(
        |||
          sum(
            rate(
              celery_tasks_total{namespace=~"^namespace$", name=~"^$celery_task_name$", state=~"^$celery_task_state$"}[5m]))
          by (name, state)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{ name }} / {{ state }}',
      )),

    celeryTasksRuntimeRate: common.graphPanel {
      title: 'Celery Tasks Runtime Rate',
      description: 'Celery Tasks Runtime Rate',
      span: 5,
      }
      .addTarget(prometheus.target(
        |||
          sum(
            rate(
              celery_tasks_runtime_seconds_bucket{namespace=~"^$namespace$", name=~"^$celery_task_name$"}[5m]))
          by (le)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{ name }} / {{ state }}',
      )),

    celeryTasksLatency: common.graphPanel {
      title: 'Celery Tasks Latency Rate',
      description: 'Celery Tasks Latency Rate',
      span: 5,
      }
      .addTarget(prometheus.target(
        |||
          sum(
            rate(
              celery_tasks_latency_seconds_bucket{namespace=~"^$namespace$", name=~"^$celery_task_name$"}[5m]))
          by (le)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{ le }}',
      )),

    celeryTopTasks: common.graphPanel {
      title: 'Celery Tasks (Top 15)',
      description: 'Celery Tasks (Top 15)',
      span: 5,
      }
      .addTarget(prometheus.target(
        |||
          topk(15,
            sum(
              rate(
                celery_tasks_total{namespace=~"^$namespace$"}[5m])))
            by (name)
        ||| % $._config,
          format='time_series',
          hide=false,
          interval='',
          intervalFactor=1,
          legendFormat='{{ name }}',
      )),

    celeryNumWorkers: common.graphPanel {
    title: 'Number of Workers',
    description: 'Number of Workers up over time',
    }.addTarget(
      grafana.prometheus.target(
        |||
          sum(avg_over_time(celery_workers{namespace=~"^$namespace$"}[5m]))
        |||
      )
    ),
  }
}