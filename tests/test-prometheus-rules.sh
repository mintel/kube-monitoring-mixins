test_prometheus_rules_promtool_success() {
	for file in `find ../rules -type f -name "*.yaml" -or -name "*.yml"` ; do
		cat $file | gojsontoyaml -yamltojson | jq -e .spec | gojsontoyaml > /tmp/test-prom-rules.yaml
		assert_status_code "0" "promtool check rules /tmp/test-prom-rules.yaml" "$file has failed promtool check rules - "
		rm -f /tmp/test-prom-rules.yaml
  done
}

test_prometheus_rules_yaml_syntax() {
	for file in `find ../rules -type f -name "*.yaml" -or -name "*.yml"` ; do
		assert_status_code "0" "cat $file | gojsontoyaml -yamltojson | jq ." "$file yaml syntax is not Valid - "
	done
}

test_prometheus_rules_have_runbook_url_set() {
	for file in `find ../rules -type f -name "*.yaml" -or -name "*.yml"` ; do
		assert_status_code "0" "cat $file | gojsontoyaml -yamltojson | jq -e -r '.spec.groups[] | select(.name|test(\"^mintel-.*\")).rules[] | select(.alert) | .annotations.runbook_url'" "$file has some rules with no runbook_url defined - "
	done
}
