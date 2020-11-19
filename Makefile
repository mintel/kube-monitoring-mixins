SHELL = /bin/bash

JSONNET_FMT := jsonnet fmt -n 2 --max-blank-lines 2 --string-style s --comment-style s
JSONNET_CMD := jsonnet -J vendor
JSONNETBUNDLERCMD=jb
RENDERED_DASHBOARDS="dashboards"
RENDERED_RULES="rules"

all: install dashboards rules test

CONTAINER_CMD:=docker run --rm -it \
	-u="$(shell id -u):$(shell id -g)" \
	-v $$(pwd):/src/satoshi/kube-monitoring-mixins/ \
	--workdir /src/satoshi/kube-monitoring-mixins \
	mintel/satoshi-gitops-ci:0.13.0

clean:
	$(CONTAINER_CMD) make _clean
rules:
	$(CONTAINER_CMD) make _rules
dashboards:
	$(CONTAINER_CMD) make _dashboards
test:
	$(CONTAINER_CMD) make _test
install:
	$(CONTAINER_CMD) make _install
diff:
	$(CONTAINER_CMD) make _diff

_clean:
	# Remove all files and directories ignored by git.
	git clean -Xfd .

_rules:
	@mkdir -p $(RENDERED_RULES)
	@rm -f $(RENDERED_RULES)/*.yaml
	$(JSONNET_CMD) -m $(RENDERED_RULES) prometheus-rules.jsonnet \
		| xargs -I{} sh -c 'cat {} \
		| gojsontoyaml > {}.yaml; rm -f {}' -- {}

_dashboards:
	@mkdir -p $(RENDERED_DASHBOARDS)/rendered
	@rm -rf $(RENDERED_DASHBOARDS)/rendered/*.json
	$(JSONNET_CMD) -J lib/mintel/dashboards -m $(RENDERED_DASHBOARDS)/rendered dashboards.jsonnet

_test:
	@cd tests; \
	bash_unit -f tap *

_install:
	$(JSONNETBUNDLERCMD) install
	# Hack kubernetes-mixin to FC Fork until https://github.com/kubernetes-monitoring/kubernetes-mixin/pull/517 is merged
	@rm -f vendor/kubernetes-mixin
	@cp -a vendor/kubernetes-mixin-primeroz vendor/kubernetes-mixin

_diff: _install _dashboards _rules
	@git status
	git --no-pager diff --exit-code dashboards rules

.PHONY: _clean _install _rules _dashboards _diff _test clean install rules dashboards diff test
