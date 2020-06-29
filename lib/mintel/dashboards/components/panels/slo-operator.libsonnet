local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

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

  serviceLevelAvailabilityBreachesTimeSeries(namespace='$namespace', sloService='$slo_service', slo='.*', interval='30s', span=6)::
    local config = {
      slo_selector: std.format('namespace="%s", service_level="%s", slo=~"%s"', [namespace, sloService, slo]),
      interval: interval,
    };

    commonPanels.timeseries(
      title='Availability Breaches and Burn Rate',
      description='Breaches of availability over time, error ratio > threshold',
      decimals=0,
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
        ||| % config,
        legendFormat='Budget Burn Rate',
        interval=config.interval,
        intervalFactor=1,
      )
    ).addTarget(
      promQuery.target(
        |||
          ( 1 - service_level_slo_objective_ratio{%(slo_selector)s} )
          * increase(service_level_sli_result_count_total{%(slo_selector)s}[%(interval)s])
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
      max=1,
      label='Breach',
    ),
}
