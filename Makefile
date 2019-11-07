SHELL = /bin/bash

JSONNET_FMT := jsonnet fmt -n 2 --max-blank-lines 2 --string-style s --comment-style s
JSONNET_CMD := jsonnet -J vendor
JSONNETBUNDLERCMD=jb
RENDERED_DASHBOARDS="rendered/dashboards"
RENDERED_RULES="rendered/rules"

all: install dashboards rules test

clean:
	# Remove all files and directories ignored by git.
	git clean -Xfd .

rules:
	@mkdir -p $(RENDERED_RULES)
	@rm -f $(RENDERED_RULES)/*.yaml
	$(JSONNET_CMD) -m $(RENDERED_RULES) prometheus-rules.jsonnet \
		| xargs -I{} sh -c 'cat {} \
		| gojsontoyaml > {}.yaml; rm -f {}' -- {}

dashboards:
	@mkdir -p $(RENDERED_DASHBOARDS)/kube-prometheus
	@rm -rf $(RENDERED_DASHBOARDS)/kube-prometheus/*.json
	$(JSONNET_CMD) -m $(RENDERED_DASHBOARDS)/kube-prometheus dashboards.jsonnet

test:
	@cd tests; \
	bash_unit -f tap *

install:
	$(JSONNETBUNDLERCMD) install

diff: install dashboards rules
	@git status
	git --no-pager diff --exit-code dashboards rules

.PHONY: clean install rules dashboards diff test
