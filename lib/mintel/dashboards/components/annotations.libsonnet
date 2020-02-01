local grafana = import 'grafonnet/grafana.libsonnet';
local annotation = grafana.annotation;
local flux_datasource='Elasticsearch-fluxcloud';

{
  fluxRelease::
    annotation.datasource(
      datasource=flux_datasource,
      name='flux-release',
      iconColor='#96D98D',
    ) +
    {
        "query": "message.EventType:release AND message.Namespaces: \"$namespace\"",
        "tagsField": "message.Tags",
        "textField": "message.Body",
    },
  fluxAutoRelease::
    annotation.datasource(
      datasource=flux_datasource,
      name='flux-autorelease',
      iconColor='#FADE2A',
    ) +
    {
        "query": "message.EventType:autorelease AND message.Namespaces: \"$namespace\"",
        "tagsField": "message.Tags",
        "textField": "message.Body",
    },

}