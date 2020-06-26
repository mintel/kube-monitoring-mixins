local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

local convertTimeUnitsToMinutesInt(time) =
  (
    local convert =
      if std.endsWith(time, 'm') then [1, 1]
      else if std.endsWith(time, 's') then [1, 0.0166667]
      else if std.endsWith(time, 'h') then [1, 60]
      else if std.endsWith(time, 'd') then [1, 1440]
      else error 'Unknown time unit suffix in ' + time;
    local string_len = std.length(time);
    std.parseInt(std.substr(time, 0, string_len - convert[0])) * convert[1]
  );

{
  serviceLevelAvailabilityOverTime(namespace='$namespace', sloService='$slo_service', slo='.*', availabilitySpan='$slo_availability_span', span=3)::
    local config = {
      slo_selector: std.format('namespace="%s", service_level="%s", slo=~"%s"', [namespace, sloService, slo]),
      availabilitySpan: availabilitySpan,
    };

    commonPanels.singlestat(
      title=std.format('Availability over %s', config.availabilitySpan),
      decimals=2,
      format='percentunit',
      thresholds='0.99',
      sparklineShow=false,
      instant=true,
      span=span,
      valueName='current',
      intervalFactor=1,
      query=|||
        1 - max(
                 (
                 increase(service_level_sli_result_error_ratio_total{%(slo_selector)s}[%(availabilitySpan)s])
                 /
                 increase(service_level_sli_result_count_total{%(slo_selector)s}[%(availabilitySpan)s])
                 )
            )
      ||| % config
    ),
}
