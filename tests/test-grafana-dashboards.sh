test_grafana_dashboards_json_syntax() {
	for file in `find ../rendered/dashboards -type f -name "*.json"` ; do
		assert_status_code "0" "cat $file | jq ." "$file yaml syntax is not Valid - "
	done
}
