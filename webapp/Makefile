GIT_TAG ?= master
# Must be later than d69f1a7 for web app

biothings-webapp:
	docker build \
		--build-arg GIT_TAG=${GIT_TAG} \
		--tag biothings-webapp:${GIT_TAG} .

all: biothings-webapp
