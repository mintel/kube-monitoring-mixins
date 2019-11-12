{
  prometheusRules+:: {
    groups+: [
      {
        name: 'elasticsearch.rules',
        rules: [
          {
            expr: '100 * (elasticsearch_filesystem_data_size_bytes - elasticsearch_filesystem_data_free_bytes) / elasticsearch_filesystem_data_size_bytes',
            record: 'elasticsearch_filesystem_data_used_percent',
          },
          {
            expr: '100 - elasticsearch_filesystem_data_used_percent',
            record: 'elasticsearch_filesystem_data_free_percent',
          },
          {
            expr: 'count by (cluster,role,namespace,job) (elasticsearch_nodes_roles{role="client"}==1)',
            record: 'elasticsearch_cluster_number_of_client_nodes',
          },
          {
            expr: 'count by (cluster,role,namespace,job) (elasticsearch_nodes_roles{role="ingest"}==1)',
            record: 'elasticsearch_cluster_number_of_ingest_nodes',
          },
          {
            expr: 'count by (cluster,role,namespace,job) (elasticsearch_nodes_roles{role="master"}==1)',
            record: 'elasticsearch_cluster_number_of_master_nodes',
          },
          {
            expr: 'count by (cluster,role,namespace,job) (elasticsearch_nodes_roles{role="data"}==1)',
            record: 'elasticsearch_cluster_number_of_data_nodes',
          },
        ],
      },
    ],
  },
}
