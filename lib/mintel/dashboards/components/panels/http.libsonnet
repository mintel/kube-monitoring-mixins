local commonPanels = import 'components/panels/common.libsonnet';
{
  httpBackendRequestsPerSecond(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    commonPanels.singlestat(
      title='Incoming Request Volume',
      description='Requests per second (all http-status)',
      colorBackground=true,
      format='rps',
      sparklineShow=true,
      span=4,
      query=|||
        sum(
          rate(
            http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
      ||| % config,
    ),

  httpBackendSuccessRatioPercentage(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    commonPanels.singlestat(
      title='Incoming Success Rate',
      description='Percentage of successful (non http-5xx) requests',
      colorBackground=true,
      format='percent',
      sparklineShow=true,
      thresholds="99,95",
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      span=4,
      query=|||
        100 - (
          sum by (service, app_mintel_com_owner)
            (
              rate(http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s", status_code=~"5.."}[$__interval])
                  or 0 * up{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}
            )

          /
          sum by (service, app_mintel_com_owner)
            (
              rate(http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval])
                or 0 * up{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}
            )
        ) * 100
      ||| % config,
    ),
}
