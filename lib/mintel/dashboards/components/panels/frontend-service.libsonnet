local layout = import 'components/layout.libsonnet';
local haproxyPanels = import 'components/panels/haproxy.libsonnet';
local workloadPanels = import 'components/panels/workloads.libsonnet';

{

  overview(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([
      workloadPanels.workloadStatus(),
      haproxyPanels.httpBackendRequestsPerSecond(config.serviceSelectorKey, config.serviceSelectorValue),
      haproxyPanels.httpBackendSuccessRatioPercentage(config.serviceSelectorKey, config.serviceSelectorValue),
    ], cols=12, rowHeight=10, startRow=startRow),
}
