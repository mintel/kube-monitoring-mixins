# kube-monitoring-mixins

## Overview

These mixins extend functionality of [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin) and provide options to override prometheus rules/alerts and grafana dashboards.

They also provide related grafana-dashboards, and (optional) GKE specific overrides.

## Dependencies

To use them, you need to have `jsonnet` (v0.13+), `jb` and `promtool` installed. If you
have a working Go development environment, it's easiest to run the following:

```bash
go get github.com/google/go-jsonnet/cmd/jsonnet
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
go get github.com/prometheus/prometheus/cmd/promtool
```

_Note: The make targets `lint` and `fmt` need the `jsonnetfmt` binary, which is
currently not included in the Go implementation of `jsonnet`. For the time
being, you have to install the [C++ version of
jsonnetfmt](https://github.com/google/jsonnet) if you want to use `make lint`
or `make fmt`._

## Usage

Import / update vendor upstream via jsonnet-bundler.
```
make install
```

Generate grafana dashboards and prometheus rules:

```
make dashboards
make rules
```

## Outputs

Prometheus rules are rendered into the `./rules` directory.

There is a `kustomization.yaml` provided which includes the generated prometheus-rules.

Grafana dashboards are rendered into the `./dashboards/kube-monitoring` directory.

## Testing

Run `promtool` and `runbook_url` validation checks, as well as general JSON/YAML linting.

```
make test
```

### Golden Tests

Check whether the rendered files match the expected output.

If these tests fail, it either means you have un-committed changes, or something upstream has changed.

```
make diff
```

## Configuration

Configuration is mostly managed through `config.jsonnet`

### GKE Overrides

GKE Specific overrides can be included by importing `./lib/gke-overrides.libsonnet`.

This file provides helpers to:

- Filter out grafana dashboards
- Filter out prometheus rule groups
- Filter out prometheus alerts
- Modify prometheus alert expressions

## Importing PrometheusRule resources

The [convert-prom-to-mixins.sh](./scripts/convert-prom-to-mixins.sh) can process a directory containing `PrometheusRule` yaml files and conver them to `.libsonnet` files which we can include in our mixins.

1. Each `.yaml` file found in the import directory is processed
2. The `group` is extracted and later used in the generated `.libsonnet` filename.
3. A file containing the alerts is generated
4. A file containing the rules is generated

You can then copy the resulting files into the `./lib/mintel` mixin directory, and configure `mixins.libsonnet` to include them.

## Additional Notes

### Kubernetes Version Support

The `jsonnetfile.json` is pinned against [kube-prometheus](https://github.com/coreos/kube-prometheus) using the latest commit on the `release-0.1` branch.

The `release-0.1` branch supports Kubernetes `v1.13`. You will want to bump this to support Kubernetes versions `v1.14` or above.

### Mintel Mixins

You can view the output of the mintel specific mixins like so:

```
cd lib/mintel
jsonnet alerts.jsonnet
jsonnet rules.jsonnet
```