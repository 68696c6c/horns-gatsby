DCR = docker-compose run --rm
IMAGE_NAME = gatsby-horns
BUILD_TAG = latest
APP_PATH = /site

.PHONY: image dep local local-down test

.DEFAULT:
	@echo 'Invalid target.'
	@echo
	@echo '    image    build the Docker image'
	@echo

default: .DEFAULT

image:
	docker build . -f ./Dockerfile -t $(IMAGE_NAME):dev

new: image
	$(DCR) app gatsby new temp
	cp -R temp/ .
	rm -rf temp
