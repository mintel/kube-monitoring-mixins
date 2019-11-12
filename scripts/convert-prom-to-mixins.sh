#!/bin/env bash
#
# Usage:
#	convert-prom-to-mixins.sh <import-directory> <output-directory
#
# This script parses existing PrometheusRule Kubernetes resources, and
# extracts rules and alerts into jsonnet.
#
# It creates a file per group.
#
# See there README.md of this repo for more information.
#
IMPORT_DIR=""
OUTPUT_DIR=""

pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

#
# Format the created jsonnet
#
function tidy_jsonnet() {
	pushd "$OUTPUT_DIR/rules"
	for f in *.libsonnet; do
		jsonnet fmt -i "$f"
	done
	popd

	pushd "$OUTPUT_DIR/alerts"
	for f in *.libsonnet; do
		jsonnet fmt -i "$f"
	done
	popd
}

#
# Helper function to write out the libsonnet. Not ideal as this could probably
# be done in a single one-liner with jq.
#
#
function write_libsonnet() {
	local filename=$1
	local content=$2
	local group=$3
	local type=$4

	prometheusKey="prometheusAlerts"
	if [ "$type" = "rules" ]; then
		prometheusKey="prometheusRules"
	fi

	cat <<- EOF > "${OUTPUT_DIR}/$type/$filename"
	{
		$prometheusKey+:: {
			groups+: [
				{
					name: '$group',
					rules: [ $content ]
				}
			]
		}
	}
	EOF
}

#
# Find all YAML in the IMPORT_DIR and extract alerts and rules.
# Attemp to write 2 files per group found (one for rules, and one for alerts)
#
function process() {

	# Find all the yaml
	pushd ${IMPORT_DIR}

	for f in *.yaml ;
	do
		# Validate that it looks like a PrometheusRule file
		printf "Importing %s\n" "${f}"

		# Find all the groups in this file
		groups=$(cat "$f" | gojsontoyaml -yamltojson | jq -r '.spec.groups[].name')

		# For each group, get the alerts, and get the rules, and write each file
		for group in $groups; do
	alerts=$(cat "$f" | gojsontoyaml -yamltojson | jq -r '.spec.groups[] | select(.name=='\"$group\"') | .rules[] | select(.alert!=null)')
			rules=$(cat "$f"| gojsontoyaml -yamltojson | jq -r '.spec.groups[] | select(.name=='\"$group\"') | .rules[] | select(.alert==null)')

			write_libsonnet "$group.libsonnet" "$rules" "$group" "rules"
			write_libsonnet "$group.libsonnet" "$alerts" "$group" "alerts"
		done
	done
	popd

}

#
# Print out usage blurb
#
function usage {
	printf "Usage:\n"
	printf "\t./convert-prom-to-mixins.sh <import-directory> <output-directory>\n\n"
	exit 1
}

# Some validation and setup input/output directory vars
if [ $# -ne 2 ]; then
    usage
fi

IMPORT_DIR=$1
OUTPUT_DIR=$2

if [ ! -d "$IMPORT_DIR" ]; then
	printf "Import directory '%s' containing yaml does not exist\n\n" "${IMPORT_DIR}"
	exit 1
fi

mkdir -p "${OUTPUT_DIR}/rules" "${OUTPUT_DIR}/alerts"

process
tidy_jsonnet
