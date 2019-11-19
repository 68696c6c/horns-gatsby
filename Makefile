DCR = docker-compose run --rm
IMAGE_NAME = gatsby-horns

.PHONY: test

.DEFAULT:
	@echo 'App targets:'
	@echo
	@echo '    image         build the Docker image'
	@echo '    new           create new project'
	@echo '    deps          install dependancies using Yarn'
	@echo '    local         spin up local Docz environment'
	@echo '    local-down    tear down local environment'
	@echo
	@echo 'DevOps targets:'
	@echo
	@echo '    pipeline-build    build the static site for use in the AWS environments'
	@echo '    env-validate      validates that the env variables required for AWS CLI calls are set'
	@echo '    cfn-test          run unit tests and cfn-lint the CloudFormation templates'
	@echo '    cfn-app           create/update the app CloudFormation stack'
	@echo '    cfn-pipeline      create/update the pipeline CloudFormation stack'
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


# Ops targets.
AWS_REGION ?= us-east-1
APP_PATH = /site

# This should NOT be overwritten since there isn't currently a way to
# pass the usual commit hash tag to the CodePipeline.
BUILD_TAG = latest

TOOLS_BASE = docker run -v $$(pwd):$(APP_PATH) -v $(HOME)/.aws:/root/.aws -w $(APP_PATH)
TOOLS_IMAGE ?= ""
TOOLS = ${TOOLS_BASE} \
			-e "AWS_REGION=$(AWS_REGION)" \
			-e "AWS_PROFILE=$(AWS_PROFILE)" \
			-e "ENVIRONMENT_NAME=$(ENVIRONMENT_NAME)" \
			$(TOOLS_IMAGE)

pipeline-image:
	docker build . -f docker/Dockerfile --target final -t $(IMAGE_NAME):$(BUILD_TAG) --pull

push: pipeline-image
	@test $(REGISTRY) || (echo "no REGISTRY"; exit 1)
	@echo "\n REGISTRY=$(REGISTRY)\n IMAGE_NAME=$(IMAGE_NAME)\n" && sleep 2
	docker tag $(IMAGE_NAME):$(BUILD_TAG) $(REGISTRY):$(BUILD_TAG)
	docker push $(REGISTRY):$(BUILD_TAG)

env-validate:
	@test $(ENVIRONMENT_NAME) || (echo "no ENVIRONMENT_NAME"; exit 1)
	@test $(AWS_REGION) || (echo "no AWS_REGION"; exit 1)
	@test $(AWS_PROFILE) || (echo "no AWS_PROFILE"; exit 1)
	@echo "ENVIRONMENT_NAME=$(ENVIRONMENT_NAME)\n AWS_REGION=$(AWS_REGION)\n AWS_PROFILE=$(AWS_PROFILE)" && sleep 2

cfn-test: env-validate
	${TOOLS_BASE} $(TOOLS_IMAGE) bash -c "cfn-lint.sh $(APP_PATH)/ops/cloudformation/*.yml"

cfn-app: cfn-test
	${TOOLS} sed 's/GIT_COMMIT/$(BUILD_TAG)/g' ops/$(ENVIRONMENT_NAME)/app.json > app.json
	${TOOLS} cfn.sh \
		$(AWS_PROFILE) \
		app.json \
		ops/cloudformation/app.yml \
		$(update)

cfn-pipeline: cfn-test
	${TOOLS} cfn.sh \
		$(AWS_PROFILE) \
		ops/$(ENVIRONMENT_NAME)/pipeline.json \
		ops/cloudformation/pipeline.yml \
		$(update)
