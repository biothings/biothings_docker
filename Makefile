# make biothings_studio
# make biothings_studio push

# uses docker-squash to reduce/prune docker layers and reduce image size
# pip install docker-squash

STUDIO_VERSION ?= master
BIOTHINGS_VERSION ?= master
BIOTHINGS_REPOSITORY ?= https://github.com/biothings/biothings.api.git
DOCKER_BUILD_EXTRA_OPTS ?= --force-rm
PYTHON_VERSION ?=

biothings-studio:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_REPOSITORY=$(BIOTHINGS_REPOSITORY) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg PROD=1 \
    -t biothings-studio:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4mygene:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg API_NAME=mygene.info \
    --build-arg API_VERSION=master \
    -t studio4mygene:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4myvariant:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg API_NAME=myvariant.info \
    --build-arg API_VERSION=master \
    -t studio4myvariant:$$(git branch | grep ^\* | sed "s#\* ##") .
	# uncomment if snpeff needs to be included in the image
	# (Seb: I tried that in order to easily run tests, but they're too heavy for travis anyways)
	### now run the container to download snpeff (easier to test after)
	##-docker kill tmpstudio && sleep 1
	##docker run --rm --name tmpstudio -p 7777:7080 -d studio4myvariant:$$(git branch | grep ^\* | sed "s#\* ##")
	##while ! curl -s localhost:7777; do echo waiting for hub api to run; sleep 5; done
	##curl -X PUT localhost:7777/source/snpeff/dump
	##sleep 10 # wait command to start
	### waiting for no commands running anymore ({} means no commands currently running
	### {"result":{},"status":"ok"} == no commands
	##while ! curl -s http://localhost:7777/commands?running=1 | jq '.result' | grep {}; do echo Waiting for Snpeff to dump/upload; sleep 30; done
	### we'll keep that container including snpeff data
	##docker commit tmpstudio studio4myvariant:master

studio4mychem:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg API_NAME=mychem.info \
    --build-arg API_VERSION=master \
    -t studio4mychem:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4mydisease:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg API_NAME=mydisease.info \
    --build-arg API_VERSION=master \
    -t studio4mydisease:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4mygeneset:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg API_NAME=mygeneset.info \
    --build-arg API_VERSION=master \
    -t studio4mygeneset:$$(git branch | grep ^\* | sed "s#\* ##") .

demohub:
	docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg BIOTHINGS_REPOSITORY=$(BIOTHINGS_REPOSITORY) \
    --build-arg API_VERSION=master \
    --build-arg TEST=1 \
    --build-arg AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) \
    --build-arg AWS_SECRET_KEY=$(AWS_SECRET_KEY) \
    -t demohub:$(BIOTHINGS_VERSION) .

demohub-test:
	DOCKER_BUILDKIT=0 docker build $(DOCKER_BUILD_EXTRA_OPTS) \
    --build-arg STUDIO_VERSION=$(STUDIO_VERSION) \
    --build-arg BIOTHINGS_VERSION=$(BIOTHINGS_VERSION) \
    --build-arg BIOTHINGS_REPOSITORY=$(BIOTHINGS_REPOSITORY) \
    --build-arg API_VERSION=master \
    --build-arg TEST=1 \
    --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
    --build-arg AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) \
    --build-arg AWS_SECRET_KEY=$(AWS_SECRET_KEY) \
    -t demohub:$(BIOTHINGS_VERSION)$(PYTHON_VERSION) .

start-demohub:
	docker-compose --file tests/hubapi/demohub/docker-compose.yml  up

stop-demohub:
	docker-compose --file tests/hubapi/demohub/docker-compose.yml down

run-test-demohub:
	pytest --rootdir tests/hubapi/demohub/testcases tests/hubapi/demohub/testcases

run:
	docker run --rm --name studio -p 8080:8080 -p 7022:7022 -p 7080:7080 -p 9001:9000 -d biothings-studio:$$(git branch | grep ^\* | sed "s#\* ##")

squash:
	$(eval CONTAINER := $(firstword $(MAKECMDGOALS)))
	docker-squash $(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##")

push:
	$(eval CONTAINER := $(firstword $(MAKECMDGOALS)))
	@echo "First tag existing image to match docker hub repo:"
	@echo "    $$ docker images # get the image ID"
	@echo "    $$ docker tag <image_id> biothings/$(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##")"
	@echo "Push the image:"
	@echo "    $$ docker push biothings/$(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##")"
