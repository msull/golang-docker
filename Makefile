VERSION=`git rev-parse HEAD`
BUILD=`date +%FT%T%z`
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Build=${BUILD}"
DOCKER_IMAGE=smallest-secured-golang-docker-image

# AWS related variables, eu-west-3 is Paris region
AWS_REGION=eu-west-3
AWS_ACCOUNT_NUMBER=123412341234


.PHONY: help
help: ## - Show help message
	@printf "\033[32m\xE2\x9c\x93 usage: make [target]\n\n\033[0m"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: docker-pull
docker-pull:	## - docker pull latest images
	@printf "\033[32m\xE2\x9c\x93 docker pull latest images\n\033[0m"
	@docker pull golang:alpine
	@docker pull python:3.9-alpine

.PHONY: build
build:docker-pull	## - Build the smallest and secured golang docker image based on scratch
	@printf "\033[32m\xE2\x9c\x93 Build the smallest and secured golang docker image based on scratch\n\033[0m"
	$(eval BUILDER_IMAGE=$(shell docker inspect --format='{{index .RepoDigests 0}}' golang:alpine))
	@export DOCKER_CONTENT_TRUST=1
	@docker build -f docker/scratch.Dockerfile --build-arg "BUILDER_IMAGE=$(BUILDER_IMAGE)" -t smallest-secured-golang .

.PHONY: build
build:docker-pull	## - Build the smallest and secured golang docker image based on scratch
	@printf "\033[32m\xE2\x9c\x93 Build the smallest and secured golang docker image based on scratch\n\033[0m"
	$(eval BUILDER_IMAGE=$(shell docker inspect --format='{{index .RepoDigests 0}}' golang:alpine))
	@export DOCKER_CONTENT_TRUST=1
	@docker build -f docker/scratch.Dockerfile --build-arg "BUILDER_IMAGE=$(BUILDER_IMAGE)" -t smallest-secured-golang .


.PHONY: build
build-python:docker-pull	## - Build the smallest and secured golang docker image based on python
	@printf "\033[32m\xE2\x9c\x93 Build the smallest and secured golang docker image based on scratch\n\033[0m"
	$(eval BUILDER_IMAGE=$(shell docker inspect --format='{{index .RepoDigests 0}}' golang:alpine))
	@export DOCKER_CONTENT_TRUST=1
	@docker build -f docker/python-alpine.Dockerfile --build-arg "BUILDER_IMAGE=$(BUILDER_IMAGE)" -t golang-python-wrapper .


.PHONY: build-no-cache
build-no-cache:docker-pull	## - Build the smallest and secured golang docker image based on scratch with no cache
	@printf "\033[32m\xE2\x9c\x93 Build the smallest and secured golang docker image based on scratch\n\033[0m"
	$(eval BUILDER_IMAGE=$(shell docker inspect --format='{{index .RepoDigests 0}}' golang:alpine))
	@export DOCKER_CONTENT_TRUST=1
	@docker build --no-cache -f docker/scratch.Dockerfile --build-arg "BUILDER_IMAGE=$(BUILDER_IMAGE)" -t smallest-secured-golang .

.PHONY: ls
ls: ## - List 'smallest-secured-golang' docker images
	@printf "\033[32m\xE2\x9c\x93 Look at the size dude !\n\033[0m"
	@docker image ls smallest-secured-golang

.PHONY: run
run:	## - Run the smallest and secured golang docker image based on scratch
	@printf "\033[32m\xE2\x9c\x93 Run the smallest and secured golang docker image based on scratch\n\033[0m"
	@docker run smallest-secured-golang:latest

.PHONY: push-to-aws
push-to-aws:	## - Push docker image to AWS Elastic Container Registry
	@aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_NUMBER).dkr.ecr.$(AWS_REGION).amazonaws.com
	@docker tag smallest-secured-golang:latest $(AWS_ACCOUNT_NUMBER).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DOCKER_IMAGE):$(VERSION)
	@docker push $(AWS_ACCOUNT_NUMBER).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DOCKER_IMAGE):$(VERSION)