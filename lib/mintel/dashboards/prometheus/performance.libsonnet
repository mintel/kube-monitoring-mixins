local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local link = grafana.link;

local templates = import 'components/templates.libsonnet';
local prometheus = import 'components/panels/prometheus.libsonnet';
local containers = import 'components/panels/containers.libsonnet';
local layout = import 'components/layout.libsonnet';

// Dashboard settings
local dashboardTitle = 'Prometheus / Performances';
local dashboardDescription = 'Provides an overview of Prometheus Performances';
local dashboardFile = 'prometheus-performances.json';

local dashboardUID = std.md5(dashboardFile);
local dashboardLink = '/d/' + std.md5(dashboardFile);

local dashboardTags = ['prometheus', 'performances'];

local config = {
  jobSelector: 'job="prometheus-k8s"',
};

// End dashboard settings
{
  grafanaDashboards+:: {
    [std.format('%s', dashboardFile)]:
      dashboard.new(
        '%(dashboardNamePrefix)s %(dashboardTitle)s' %
        ($._config.mintel { dashboardTitle: dashboardTitle }),
        time_from='now-6h',
        uid=dashboardUID,
        tags=($._config.mintel.dashboardTags) + dashboardTags,
        description=dashboardDescription,
        graphTooltip='shared_crosshair',
        editable=true,
      )

      .addTemplate(templates.ds)
      .addTemplate(templates.generic_up_label_values(config.jobSelector, 'prometheus', 'pod', includeAll=false, multiValue=false))

      .addRow(
        row.new('Overview', height=5)
        .addPanels(containers.podResourcesRow(namespace='monitoring', pod='$prometheus', container='prometheus', title='prometheus container'))
        .addPanel(prometheus.allErrors(selector=config.jobSelector, span=6))
        .addPanel(prometheus.memoryUsage(selector=config.jobSelector))
      )
      .addRow(
        row.new('Ingestion', height=5, collapse=true)
        .addPanels([
          prometheus.skippedScrapes(selector=config.jobSelector, span=1),
          prometheus.scrapeCacheFlush(selector=config.jobSelector, span=1),
          prometheus.averageChunkSize(selector=config.jobSelector, span=1),
          prometheus.averageChunkSamples(selector=config.jobSelector, span=1),
          prometheus.headTimeSeries(selector=config.jobSelector),
          prometheus.headTimeSeriesRates(selector=config.jobSelector),
        ])
        .addPanels([
          prometheus.seriesCreatedRemoved(selector=config.jobSelector),
          prometheus.headChunks(selector=config.jobSelector),
          prometheus.headChunksOperations(selector=config.jobSelector),
        ])
        .addPanels([
          prometheus.scrapeDurationWorstJobsInstances(),
          prometheus.scrapesPercentile(config.jobSelector),
          prometheus.largetsSampleJobsInstance(),
        ])
      )
      .addRow(
        row.new('Query Engine', height=5, collapse=true)
        .addPanels([
          prometheus.queriesRunningAverage(selector=config.jobSelector),
          prometheus.queriesSliceOps(selector=config.jobSelector),
          prometheus.queriesSliceLatency(selector=config.jobSelector),
          prometheus.rulesEvaluationAverageLatency(selector=config.jobSelector, span=6),
          prometheus.rulesLastDurationTop(selector=config.jobSelector, topk=5, span=6),
          prometheus.httpRequests(selector=config.jobSelector),
          prometheus.httpRequestsLatency(selector=config.jobSelector),
          prometheus.httpRequestsTimeSpent(selector=config.jobSelector),
        ])
      )
      .addRow(
        row.new('Storage', height=5, collapse=true)
        .addPanels([
          prometheus.tsdbStoragetBlockSize(selector=config.jobSelector, span=2),
          prometheus.fileDescriptors(selector=config.jobSelector, span=2),
          prometheus.activeDataBlocks(selector=config.jobSelector),
          prometheus.tsdbBlocksReload(selector=config.jobSelector),
          prometheus.averageWalFsync(selector=config.jobSelector),
          prometheus.averageCompactionTime(selector=config.jobSelector),
          prometheus.tsdbCompactions(selector=config.jobSelector),
          prometheus.tsdbCutoffs(selector=config.jobSelector),
        ])
      ),
  },
}
