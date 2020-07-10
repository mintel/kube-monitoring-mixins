local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{
  local commonVars = {
    sum_by_labels: 'namespace, service_level, slo',
  },

  serviceLevelAvailabilityOverTime(namespace='$namespace', sloService='$slo_service', slo='.*', availabilitySpan='$slo_availability_span', span=3)::
    local config = {
      slo_selector: std.format('namespace="%s", service_level="%s", slo=~"%s"', [namespace, sloService, slo]),
      availabilitySpan: availabilitySpan,
      sum_by_labels: commonVars.sum_by_labels,
    };

    commonPanels.singlestat(
      title=std.format('Availability over %s', config.availabilitySpan),
      decimals=5,
      format='percentunit',
      thresholds='0.99',
      sparklineShow=false,
      instant=true,
      span=span,
      valueName='current',
      intervalFactor=1,
      query=|||
        1 - (
                 (
                 sum by (%(sum_by_labels)s) (increase(service_level_sli_result_error_ratio_total{%(slo_selector)s}[%(availabilitySpan)s]))
                 /
                 sum by (%(sum_by_labels)s) (increase(service_level_sli_result_count_total{%(slo_selector)s}[%(availabilitySpan)s]))
                 )
            )
      ||| % config
    ),

  serviceLevelAvailabilityBreachesTimeSeries(namespace='$namespace', sloService='$slo_service', slo='.*', interval='30s', span=6)::
    local config = {
      slo_selector: std.format('namespace="%s", service_level="%s", slo=~"%s"', [namespace, sloService, slo]),
      interval: interval,
    };

    commonPanels.timeseries(
      title='Availability Breaches and Burn Rate',
      description='Breaches of availability over time, error ratio > threshold',
      decimals=2,
      format='none',
      span=span,
      legend_show=false,
      legendFormat='breach',
      height=200,
      interval=config.interval,
      intervalFactor=1,
      query=|||
        (
          increase(service_level_sli_result_error_ratio_total{%(slo_selector)s}[%(interval)s])
          /
          increase(service_level_sli_result_count_total{%(slo_selector)s}[%(interval)s])
        ) > bool (1 - service_level_slo_objective_ratio)
      ||| % config
    ).addTarget(
      promQuery.target(
        |||
          increase(service_level_sli_result_error_ratio_total{%(slo_selector)s}[%(interval)s])
          /
          increase(service_level_sli_result_count_total{%(slo_selector)s}[%(interval)s])
        ||| % config,
        legendFormat='Budget Burn Rate',
        interval=config.interval,
        intervalFactor=1,
      )
    ).addTarget(
      promQuery.target(
        |||
          ( 1 - service_level_slo_objective_ratio{%(slo_selector)s} )
        ||| % config,
        legendFormat='Max Budget',
        interval=config.interval,
        intervalFactor=1,
      )
    )
    .addSeriesOverride(
      {
        alias: 'breach',
        lines: false,
        nullPointMode: 'null as zero',
        color: '#E02F44',
        bars: true,
        yaxis: 2,
        zindex: '-3',
        hideTooltip: true,
      },
    )
    .addSeriesOverride(
      {
        alias: 'Budget Burn Rate',
        nullPointMode: 'connected',
        color: '#FADE2A',
        zindex: 1,
        fill: 1,
      },
    )
    .addSeriesOverride(
      {
        alias: 'Max Budget',
        nullPointMode: 'connected',
        color: '#B877D9',
        zindex: 0,
        fill: 1,
      },
    )
    .resetYaxes()
    .addYaxis(
      format='none',
      min=0,
      show=false,
      max=null,
      label='Burn Rate',
    )
    .addYaxis(
      format='short',
      min=0,
      show=false,
      max=1,
      label='Breach',
    ),

  serviceLevelBurndownStat(namespace='$namespace', sloService='$slo_service', slo='.*', projection='week', span=3)::
    local config = {
      slo_selector: std.format('namespace="%s", service_level="%s", slo=~"%s"', [namespace, sloService, slo]),
      projection_string: if projection == 'week' then '7d' else '30d',  // Week or anything else is 1 month
      minutes_multiplier: if projection == 'week' then 10080 else 43200,  // Week or anything else is 1 month
      interval_in_minutes: 10,
      multiplier: config.minutes_multiplier / config.interval_in_minutes,
    };

    commonPanels.singlestat(
      title=std.format('Error Budget left for the current %s', config.projection_string),
      format='percent',
      span=span,
      height=200,
      decimals=5,
      thresholds='0.99, 0.95',  // Can we make this dynamic ?
      sparklineShow=false,
      instant=true,
      valueName='current',
      intervalFactor=1,
      query=|||
        (
          (
            (1 - service_level_slo_objective_ratio{%(slo_selector)s}) * %(multiplier)s * increase(service_level_sli_result_count_total{%(slo_selector)s}[%(interval_in_minutes)sm])
            -
            increase(service_level_sli_result_error_ratio_total{%(slo_selector)s}[${__range}])
          )
          /
          (
            (1 - service_level_slo_objective_ratio{%(slo_selector)s}) * %(multiplier)s * increase(service_level_sli_result_count_total{%(slo_selector)s}[%(interval_in_minutes)sm])
          )
        ) * 100
      ||| % config
    ),
}
