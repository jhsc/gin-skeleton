APP_NAME=app
APP_VERSION=0.0.1
DOCKER_IMAGE_NAME=jhsc/app
# LDFLAGS=--ldflags '-X main.version=${APP_VERSION} -X main.appName=${APP_NAME} -extldflags "-static" -w -s'

PACKAGES=$(shell go list ./... | grep -v /vendor/)
OS=linux
.DEFAULT_GOAL := help

.PHONY: test
test: ## Run the unit tests
	go test -v -race $(PACKAGES)

.PHONY: lint
lint: ## Lint all files
	gometalinter.v2 $(PACKAGES)

.PHONY: clean
clean: ## Clean up
	@rm -fR ./build/

.PHONY: dep
dep: ## Download dependencies
	dep ensure -v && dep prune

.PHONY: build
build: clean ## Build app
	go build -v -o ./build/${APP_NAME} ./cmd/app
	# CGO_ENABLED=0 GOOS=${OS} go build -v -a -installsuffix cgo -o ./build/${APP_NAME} ./cmd/app
.PHONY: build

.PHONY: docker-build
docker-build: ## Build Docker image
	docker build -f $(DOCKER_IMAGE_NAME)

.PHONY: docker-push
docker-push: ## Push Docker image to registry
	docker push $(DOCKER_IMAGE_NAME)

.PHONY: help
help: ## Display help message
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'