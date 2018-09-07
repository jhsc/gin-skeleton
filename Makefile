APP_NAME=app
APP_VERSION=0.0.1
DOCKER_IMAGE_NAME=jhsc/app
# LDFLAGS=--ldflags '-X main.version=${APP_VERSION} -X main.appName=${APP_NAME} -extldflags "-static" -w -s'

PACKAGES=$(shell go list ./... | grep -v /vendor/)
OS=linux
.DEFAULT_GOAL := help

# Run the unit tests
.PHONY: test
test:
	go test -v -race $(PACKAGES)

# Lint all files
.PHONY: lint
lint:
	gometalinter.v2 $(PACKAGES)

# Clean up
.PHONY: clean
clean:
	@rm -fR ./build/

# Download dependencies
.PHONY: dep
dep:
	dep ensure -v && dep prune

# Build app
.PHONY: build
build: clean
	go build -v -o ./build/${APP_NAME} ./cmd/app
	# CGO_ENABLED=0 GOOS=${OS} go build -v -a -installsuffix cgo -o ./build/${APP_NAME} ./cmd/app
.PHONY: build

# Build Docker image
.PHONY: docker-build
docker-build:
	docker build -f $(DOCKER_IMAGE_NAME)

# Push Docker image to registry
.PHONY: docker-push
docker-push:
	docker push $(DOCKER_IMAGE_NAME)

# Display this help message
.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'