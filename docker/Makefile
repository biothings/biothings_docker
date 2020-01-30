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
