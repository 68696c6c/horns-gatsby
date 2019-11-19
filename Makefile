DCR = docker-compose run --rm
IMAGE_NAME = gatsby-horns
BUILD_TAG = latest
APP_PATH = /site

.PHONY: test

.DEFAULT:
	@echo 'App targets'
	@echo
	@echo '    image         build the Docker image'
	@echo '    new           create new project'
	@echo '    deps          install dependancies using Yarn'
	@echo '    local         spin up local Docz environment'
	@echo '    local-down    tear down local environment'
	@echo

default: .DEFAULT

image:
	docker build . -f ./Dockerfile -t $(IMAGE_NAME):dev

new: image
	$(DCR) app gatsby new temp
	cp -R temp/ .
	rm -rf temp

deps:
	$(DCR) app yarn

local: local-down
	NETWORK_NAME="$(NETWORK_NAME)" docker-compose up

local-down:
	NETWORK_NAME="$(NETWORK_NAME)" docker-compose down
