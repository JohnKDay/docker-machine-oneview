
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

release-x:
	$(if $(VERSION), , \
		$(error Pass the version number as the first arg. E.g.: VERSION=1.2.3 make release))
	$(if $(GITHUB_TOKEN), , \
		$(error GITHUB_TOKEN must be set for github-release. E.g.: GITHUB_TOKEN=XXX VERSION=$(VERSION) make release))
	@echo 'Performing release $(VERSION)'
	@echo `bash -c 'GITHUB_TOKEN=$(GITHUB_TOKEN) GITHUB_USER=$(GH_USER) GITHUB_REPO=$(GH_REPO) $(current_dir)/../build/release.sh $(VERSION)'`
