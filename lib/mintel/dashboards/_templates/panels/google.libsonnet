local commonPanels = import '_templates/panels/common.libsonnet';
local layout = import '_templates/utils/layout.libsonnet';
local promQuery = import '_templates/utils/prom_query.libsonnet';
local seriesOverrides = import '_templates/utils/series_overrides.libsonnet';
{
  bucketPanels(serviceType, startRow)::
    local config = {
      serviceType: serviceType,
    };
    layout.grid([
      commonPanels.singlestat(
        title='Pods Available',
        query=|||
          sum(up{service="$service", namespace="$namespace"})
      ||| % config,
      ),
      commonPanels.singlestat(
        title='2xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"2.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='3xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"3.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='4xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"4.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),
      commonPanels.singlestat(
        title='5xx Responses',
        query=|||
          sum(rate(django_http_responses_total_by_status_total{status=~"5.+", namespace=~"$namespace", service=~"^$service$"}[5m]))
      ||| % config,
      ),

    ], cols=5, rowHeight=5, startRow=startRow),
}
