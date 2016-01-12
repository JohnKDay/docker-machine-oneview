# Initialize version and gc flags
GO_LDFLAGS := -X `go list ./version`.GitCommit=`git rev-parse --short HEAD`
GO_GCFLAGS :=

# Full package list
# PKGS := $(shell go list -tags "$(BUILDTAGS)" ./oneview/... | grep -v "/vendor/" | grep -v "/Godeps/")
PKGS := ./cmd/... ./oneview/... ./version/...


# Resolving binary dependencies for specific targets
GOLINT_BIN := $(GOPATH)/bin/golint
GOLINT := $(shell [ -x $(GOLINT_BIN) ] && echo $(GOLINT_BIN) || echo '')

# Support go1.5 vendoring (let us avoid messing with GOPATH or using godep)
ifneq ($(GO15VENDOREXPERIMENT),1)
GOPATH := $(GOPATH):$(PREFIX)/Godeps/_workspace
endif

# Honor debug
# note when compiling directly on mac with DEBUG option i was getting this error:
# runtime.cgocallbackg: nosplit stack overflow
# if you get this try unset DEBUG
ifeq ($(DEBUG),true)
	# Disable function inlining and variable registerization
	GO_GCFLAGS := -gcflags "-N -l"
else
	# Turn of DWARF debugging information and strip the binary otherwise
	GO_LDFLAGS := $(GO_LDFLAGS) -w -s
endif

# Honor static
ifeq ($(STATIC),true)
	# Append to the version
	GO_LDFLAGS := $(GO_LDFLAGS) -extldflags -static
endif

# Honor verbose
VERBOSE_GO :=
GO := go
ifeq ($(VERBOSE),true)
	VERBOSE_GO := -v
	GO := go
endif

include mk/build.mk
# include mk/coverage.mk
include mk/release.mk
include mk/test.mk
include mk/validate.mk

.all_build: build build-clean build-x build-machine build-plugins
# .all_coverage: coverage-generate coverage-html coverage-send coverage-serve coverage-clean
.all_test: test-short test-long test-integration
.all_validate: dco fmt vet lint

# Build native machine and all drivers
default: build
build: godeps-init-oneview build-x
release: clean test build release-x
clean: coverage-clean build-clean
test: check test-short
check: godeps-init-oneview dco fmt vet lint
validate: check test-short test-long
cross: build-x
install:
	cp ./bin/docker-machine* /usr/local/bin/

.PHONY: .all_build .all_coverage .all_release .all_test .all_validate test build validate clean
