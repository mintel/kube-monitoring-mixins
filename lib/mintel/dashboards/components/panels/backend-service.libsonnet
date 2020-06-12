local layout = import 'components/layout.libsonnet';
local workloadPanels = import 'components/panels/workloads.libsonnet';
local httpPanels = import 'components/panels/http.libsonnet';

{

  overview(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([
      workloadPanels.workloadStatus(),
      httpPanels.httpBackendRequestsPerSecond(config.serviceSelectorKey, config.serviceSelectorValue),
      httpPanels.httpBackendSuccessRatioPercentage(config.serviceSelectorKey, config.serviceSelectorValue),

    ], cols=12, rowHeight=10, startRow=startRow),
}
