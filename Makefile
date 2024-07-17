NAME=tcping
BASE_BUILDDIR=build
BUILDNAME=$(GOOS)-$(GOARCH)$(GOARM)
BUILDDIR=$(BASE_BUILDDIR)/$(BUILDNAME)
VERSION?=dev
GIT_COMMIT?=$(shell git rev-parse HEAD)

ifeq ($(GOOS),windows)
  ext=.exe
  archiveCmd=zip -9 -r $(NAME)-$(BUILDNAME)-$(VERSION).zip $(BUILDNAME)
else
  ext=
  archiveCmd=tar czpvf $(NAME)-$(BUILDNAME)-$(VERSION).tar.gz $(BUILDNAME)
endif

.PHONY: default
default: build

.PHONY: vendor
vendor:
	go mod vendor

.PHONY: build
build: clean test vendor
	go build -mod=vendor

.PHONY: release
release: check-env-release vendor
	mkdir -p $(BUILDDIR)
	cp LICENSE $(BUILDDIR)/
	cp README.md $(BUILDDIR)/
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -mod=vendor -ldflags "-s -w -X main.version=$(VERSION) -X main.gitCommit=$(GIT_COMMIT)" -o $(BUILDDIR)/$(NAME)$(ext)
	cd $(BASE_BUILDDIR) ; $(archiveCmd)

.PHONY: test
test:
	go test -race -v -bench=. ./...

.PHONY: clean
clean:
	go clean
	rm -rf $(BASE_BUILDDIR)

.PHONY: check-env-release
check-env-release:
	@ if [ "$(GOOS)" = "" ]; then \
		echo "Environment variable GOOS not set"; \
		exit 1; \
	fi
	@ if [ "$(GOARCH)" = "" ]; then \
		echo "Environment variable GOOS not set"; \
		exit 1; \
	fi
