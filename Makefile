VERSION := '1.0.1'
EXECUTABLE := drone-email
TAGS ?=
LDFLAGS ?= -X 'main.version=$(VERSION)'
TMPDIR := $(shell mktemp -d 2>/dev/null || mktemp -d -t 'tempdir')
SOURCES ?= $(shell find . -name "*.go" -type f)

ifneq ($(shell uname), Darwin)
	EXTLDFLAGS = -extldflags "-static" $(null)
else
	EXTLDFLAGS =
endif

.PHONY: all

all: build docker deploy

docker:
	@docker build -t garychen/drone-email .

.PHONY: build
build: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	@dep ensure
	@GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -tags '$(TAGS) netgo' -ldflags '$(EXTLDFLAGS)-s -w $(LDFLAGS)' -o bin/linux/osx/$@
	@GOOS=linux  GOARCH=amd64 CGO_ENABLED=0 go build -tags '$(TAGS) netgo' -ldflags '$(EXTLDFLAGS)-s -w $(LDFLAGS)' -o bin/linux/amd64/$@
	@GOOS=linux  GOARCH=arm64 CGO_ENABLED=0 go build -v -tags '$(TAGS) netgo'  -ldflags '$(EXTLDFLAGS)-s -w $(LDFLAGS)' -o bin/linux/arm64/$@
	@GOOS=linux  GOARCH=arm   CGO_ENABLED=0 GOARM=7 go build -v -tags '$(TAGS) netgo' -ldflags '$(EXTLDFLAGS)-s -w $(LDFLAGS)' -o bin/linux/arm/$@

deploy:
	@docker push garychen/drone-email:latest
