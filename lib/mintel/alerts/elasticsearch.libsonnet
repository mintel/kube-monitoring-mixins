{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'elasticsearch.alerts',
        rules: [
          {
            alert: 'ElasticsearchOperatorReconcileErrors',
            annotations: {
              description: 'ElasticSearch Operator failing to reconcile controller {{ $labels.controller }}',
              summary: 'ElasticSearch Operator failing to reconcile controller {{ $labels.controller }}',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchOperatorReconcileErrors.md' % $._config,
            },
            expr: 'increase(controller_runtime_reconcile_errors_total{%(eckOperatorFilter)s}[30m]) >0' % $._config,
            'for': '30m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchTooFewNodesRunning',
            annotations: {
              description: 'There are only {{$value}} < 3 ElasticSearch nodes running in cluster {{$labels.cluster}}',
              summary: 'ElasticSearch running on less than 3 nodes',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchTooFewNodesRunning.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_number_of_nodes < 3',
            'for': '30m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchTooFewMastersRunning',
            annotations: {
              description: 'There are only {{$value}} < 3 ElasticSearch Master nodes running in cluster {{$labels.cluster}}',
              summary: 'ElasticSearch running on less than 3 Master nodes',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchTooFewMastersRunning.md' % $._config,
            },
            expr: 'elasticsearch_cluster_number_of_master_nodes < 3',
            'for': '10m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchHeapTooHigh',
            annotations: {
              description: 'ElasticSearch instance {{$labels.name}} heap usage is high in cluster {{$labels.cluster}}',
              summary: 'The heap usage is over 80% for 15m',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchHeapTooHigh.md' % $._config,
            },
            expr: 'elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.8',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchHeapTooHigh',
            annotations: {
              description: 'ElasticSearch instance {{$labels.name}} heap usage is high in cluster {{$labels.cluster}}',
              summary: 'The heap usage is over 90% for 15m',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchHeapTooHigh.md' % $._config,
            },
            expr: 'elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.9',
            'for': '15m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchLowDiskFree',
            annotations: {
              description: 'Free Disk for elasticsearch node is lower than 30% on {{$labels.name}} in cluster {{$labels.cluster}}',
              summary: 'Low free Disk for elasticsearch node',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchLowDiskFree.md' % $._config,
            },
            expr: 'elasticsearch_filesystem_data_free_percent < 30',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchLowDiskFree',
            annotations: {
              description: 'Free Disk for elasticsearch node is lower than 15% on {{$labels.name}} in cluster {{$labels.cluster}}',
              summary: 'Low free Disk for elasticsearch node',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchLowDiskFree.md' % $._config,
            },
            expr: 'elasticsearch_filesystem_data_free_percent < 15',
            'for': '15m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchClusterHealthRED',
            annotations: {
              description: 'Cluster is RED: not all primary and replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}',
              summary: 'Cluster {{ $labels.cluster }} health is RED',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchClusterHealthRED.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_status{color="red"}==1',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchClusterHealthYELLOW',
            annotations: {
              description: 'Cluster is YELLOW: not all replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}',
              summary: 'Cluster {{ $labels.cluster }} health is YELLOW',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchClusterHealthYELLOW.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_status{color="yellow"}==1',
            'for': '120m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchClusterHealthUp',
            annotations: {
              description: 'ElasticSearch {{ $labels.cluster }} last scrape of the ElasticSearch cluster health failed',
              summary: 'ElasticSearch {{ $labels.cluster }} last scrape of the ElasticSearch cluster health failed',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchClusterHealthUp.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_up !=1',
            'for': '3m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchClusterHealthUp',
            annotations: {
              description: 'ElasticSearch {{ $labels.cluster }} last scrape of the ElasticSearch cluster health failed',
              summary: 'ElasticSearch {{ $labels.cluster }} last scrape of the ElasticSearch cluster health failed',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchClusterHealthUp.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_up !=1',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ElasticsearchGCRunsCount',
            annotations: {
              description: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: Count of JVM GC runs > 5 per sec and has a value of {{ $value }}',
              summary: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: Count of JVM GC runs > 5 per sec and has a value of {{ $value }}',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchGCRunsCount.md' % $._config,
            },
            expr: 'rate(elasticsearch_jvm_gc_collection_seconds_count{}[5m])>7',
            'for': '3m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchGCRunTime',
            annotations: {
              description: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: GC run time in seconds > 0.3 sec and has a value of {{ $value }}',
              summary: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: GC run time in seconds > 0.3 sec and has a value of {{ $value }}',
              runbook_url: '%(runBookBaseURL)s/core/ElasticsearchGCRunTime.md' % $._config,
            },
            expr: 'rate(elasticsearch_jvm_gc_collection_seconds_sum[5m])>0.3',
            'for': '3m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'Elasticsearch_breakers_tripped',
            annotations: {
              description: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: breakers tripped > 0 and has a value of {{ $value }}',
              summary: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: breakers tripped > 0 and has a value of {{ $value }}',
              runbook_url: '%(runBookBaseURL)s/core/Elasticsearch_breakers_tripped.md' % $._config,
            },
            expr: 'rate(elasticsearch_breakers_tripped{}[5m])>0',
            'for': '3m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'Elasticsearch_health_timed_out',
            annotations: {
              description: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: Number of cluster health checks timed out > 0 and has a value of {{ $value }}',
              summary: 'ElasticSearch node {{ $labels.name }} on cluster {{ $labels.cluster }}: Number of cluster health checks timed out > 0 and has a value of {{ $value }}',
              runbook_url: '%(runBookBaseURL)s/core/Elasticsearch_health_timed_out.md' % $._config,
            },
            expr: 'elasticsearch_cluster_health_timed_out>0',
            'for': '3m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'Elasticsearch_json_parse_failures',
            annotations: {
              description: 'ElasticSearch node {{ $labels.instance }}: json parse failures over an hour > 3 and has a value of {{ $value }}',
              summary: 'ElasticSearch node {{ $labels.instance }}: json parse failures over an hour > 3 and has a value of {{ $value }}',
              runbook_url: '%(runBookBaseURL)s/core/Elasticsearch_json_parse_failures.md' % $._config,

            },
            expr: 'increase(elasticsearch_cluster_health_json_parse_failures[1h]) > 3',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchSnapshotFailures',
            annotations: {
              description: 'Elastic stack {{ $labels.job }}: last snapshot has failed {{ $value }} times',
              summary: 'Elastic stack {{ $labels.job }}: last snapshot has failed {{ $value }} times',
              runbook_url: '%(runBookBaseURL)s/core/Elasticsearch.md#elasticsearchsnapshotfailures' % $._config,
            },
            expr: 'elasticsearch_snapshot_stats_snapshot_number_of_failures > 0',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ElasticsearchSnapshotRepoFailures',
            annotations: {
              description: 'Elastic stack {{ $labels.job }}: {{ $labels.repository }} respository is currently unavailable',
              summary: 'Elastic stack {{ $labels.job }}: {{ $labels.repository }} respository is currently unavailable',
              runbook_url: '%(runBookBaseURL)s/core/Elasticsearch.md#elasticsearchsnapshotrepofailures' % $._config,
            },
            expr: 'elasticsearch_snapshot_stats_repository_up == 0',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
