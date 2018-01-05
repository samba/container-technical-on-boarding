APP_NAME         = technical-on-boarding
APP_PACKAGE      = github.com/samsung-cnct/container-technical-on-boarding
APP_PATH         = ./app
APP_PATH_PKGS    = $(APP_PATH)/models $(APP_PATH)/controllers $(APP_PATH)/jobs $(APP_PATH)/jobs/onboarding

# The version and build is statically set if you cannot calculate it via git.
# Additionally if APP_VERSION or APP_BUILD is overriden (?=) then these
# values will have precedence.
GIT_VERSION      = $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
APP_VERSION     ?= $(if $(GIT_VERSION),$(GIT_VERSION),0.0.0)
GIT_HASH         = $(shell git rev-parse --short HEAD)
APP_BUILD       ?= $(if $(GIT_HASH),$(GIT_HASH),000)

IMAGE_REPO       = quay.io
IMAGE_REPO_ORG   = samsung_cnct
IMAGE_TAG       ?= local-dev
IMAGE_NAME      ?= $(IMAGE_REPO)/$(IMAGE_REPO_ORG)/$(APP_NAME):$(IMAGE_TAG)

LDFLAGS=-ldflags "-X main.Version=${APP_VERSION} -X main.Build=${APP_BUILD}"

DOCKER_RUN_OPTS  =--rm -it -p 9000:9000 --env-file ./.env
DOCKER_RUN_CMD  ?=

# Build Tools

GOMETALINTER := ${GOPATH}/bin/gometalinter.v2
$(GOMETALINTER):
	go get -u gopkg.in/alecthomas/gometalinter.v2

GLIDE := ${GOPATH}/bin/glide.v0
$(GLIDE):
	go get -u gopkg.in/masterminds/glide.v0

REVEL := ${GOPATH}/bin/revel
$(REVEL):
	go get github.com/revel/cmd/revel

# Development 

.PHONY: all
all: vendor vet build test

glide.lock: $(GLIDE) glide.yaml
	$(GLIDE) update
	@touch $@

.PHONY: vendor
vendor: glide.lock
	$(GLIDE) install

.PHONY: vet
vet: $(GOMETALINTER) 
	$(GOMETALINTER) --install
	$(GOMETALINTER) --vendored-linters \
		--disable-all \
		--enable=vet \
		--enable=gofmt \
		--enable=golint \
		--enable=gosimple \
		--sort=path \
		--aggregate \
		--vendor \
		--tests \
		$(APP_PATH)/...

.PHONY: build
build: $(APP_NAME) $(REVEL)

$(APP_NAME):
	go build -v $(LDFLAGS) $(APP_PATH_PKGS)

.PHONY: test
test: vet
	go test -race -v $(APP_PATH_PKGS)

coverage.html: $(shell find $(APP_PATH_PKGS) -name '*.go')
	go test -covermode=count -coverprofile=coverage.prof $(APP_PATH_PKGS)
	go tool cover -html=coverage.prof -o $@

.PHONY: test-cover
test-cover: coverage.html

.PHONY: clean
clean:
	-rm -vf ./coverage.* ./$(APP_NAME)
	-rm -rf ./test-results/

godoc.txt: $(shell find ./ -name '*.go')
	godoc $(APP_PATH) > $@

.PHONY: docs
docs:  godoc.txt

# Docker

docker-build: Dockerfile
	docker build --pull --force-rm \
	   --build-arg VERSION=$(APP_VERSION) \
	   --build-arg BUILD=$(APP_BUILD) \
	   -t $(IMAGE_NAME) .
	touch $@

.PHONY: docker-test
docker-test: docker-build
	docker run --rm --env-file ./template.env \
		 $(IMAGE_NAME) \
		 revel test $(APP_PACKAGE) dev

.PHONY: docker-run
docker-run: docker-build
	docker run $(DOCKER_RUN_OPTS) $(IMAGE_NAME) $(DOCKER_RUN_CMD)

.PHONY: docker-run-dev
docker-run-dev: docker-build
	docker run $(DOCKER_RUN_OPTS) \
	   -v $(GOPATH):/go \
		 -e VERSION=$(APP_VERSION) \
		 -e BUILD=$(APP_BUILD) \
	   $(IMAGE_NAME) $(DOCKER_RUN_CMD)

.PHONY: docker-clean
docker-clean:
	rm docker-build
	docker rmi $(IMAGE_NAME)
