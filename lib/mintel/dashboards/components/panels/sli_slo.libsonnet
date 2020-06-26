local constants = import '../../../constants.libsonnet';
local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{
  serviceLevelAvailabilityOverTime(backendServiceSelector='$slo_backend_service', availabilitySpan='$slo_availability_span', span=3)::
    local config = {
      backendServiceSelector: backendServiceSelector,
      availabilitySpan: availabilitySpan,
    };

    commonPanels.singlestat(
      title=std.format('Availability over %s', availabilitySpan),
      decimals=2,
      format='percentunit',
      thresholds='0.99',
      sparklineShow=false,
      instant=true,
      span=span,
      valueName='current',
      intervalFactor=1,
      query=|||
        sum_over_time(%(slo_ingress_responses_combined_metric_name)s{backend_service="%(backendServiceSelector)s"}[%(availability_span)s])
        /
        count_over_time(%(slo_ingress_responses_combined_metric_name)s{backend_service="%(backendServiceSelector)s"}[%(availability_span)s])
      ||| % (config {
               slo_ingress_responses_combined_metric_name: constants.sli_slo.slo_ingress_responses_combined_metric_name,
               availability_span: availabilitySpan,
               backendServiceSelector: backendServiceSelector,
             }),
    ),
}
