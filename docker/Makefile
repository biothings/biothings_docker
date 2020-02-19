# make biothings_studio
# make biothings_studio push

# uses docker-squash to reduce/prune docker layers and reduce image size
# pip install docker-squash

biothings-studio:
	docker build \
    --squash \
    --build-arg GITHASH=$$(git rev-parse --short HEAD) \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=master \
    --build-arg PROD=1 \
    -t biothings-studio:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4mygene:
	docker build --force-rm \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=master \
    --build-arg API_NAME=mygene.info \
    --build-arg API_VERSION=master \
    -t studio4mygene:$$(git branch | grep ^\* | sed "s#\* ##") .

studio4myvariant:
	docker build --force-rm \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=master \
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
	docker build --force-rm \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=master \
    --build-arg API_NAME=mychem.info \
    --build-arg API_VERSION=master \
    -t studio4mychem:$$(git branch | grep ^\* | sed "s#\* ##") .

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
