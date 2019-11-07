# Kubernetes Mixins

## Overview

Extend functionality of [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin) and provide options to override prometheus rules/alerts and grafana dashboards.

Also provides a `gke-overrides.libsonnet`.

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

Next, install the dependencies by running the following command in this
directory:

```bash
jb install
```


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

Renders:

- `./rendered/rules`
- `./rendered/dashboards/kube-monitoring`

### Kustomization

Note `kustomization.yaml` - this provides an easy way to use the generated
rules as a base.

## Configuration

Upstream configuration of *kubernetes-mixin* can be done in `config.jsonnet`

## Jsonnetfile.json

Note this is pinned against [kube-prometheus](https://github.com/coreos/kube-prometheus) using the latest commit on the `release-0.1` branch.

The `release-0.1` branch supports Kubernetes `v1.13`.

## GKE Overrides

GKE Specific overrides can be included by importing `./lib/gke-overrides.libsonnet`.

This file provides helpers to:

- Filter out grafana dashboards
- Filter out prometheus rule groups
- Filter out prometheus alerts
- Modify prometheus alert expressions
