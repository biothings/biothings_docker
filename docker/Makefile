# make biothings_studio
# make biothings_studio save
# makz biothings_studio sends3

biothings_studio:
	docker build \
    --build-arg GITHASH=$$(git rev-parse --short HEAD) \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=release_manager \
    -t biothings_studio:$$(git branch | grep ^\* | sed "s#\* ##") .

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
	docker run --rm --name studio -p 8080:8080 -p 7022:7022 -p 7080:7080 -p 9001:9000 -d biothings_studio:$$(git branch | grep ^\* | sed "s#\* ##")

containers:
	-mkdir containers

save: containers
	$(eval CONTAINER := $(firstword $(MAKECMDGOALS)))
	docker save $(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##") | xz > ../containers/$(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##").docker.xz 

sends3:
	$(eval CONTAINERFILE := $(firstword $(MAKECMDGOALS)))
	#aws s3 cp $(CONTAINERFILE) s3://biothings-containers/biothings_studio/
	aws s3 cp containers/$(CONTAINERFILE):$$(git branch | grep ^\* | sed "s#\* ##").docker.xz s3://biothings-containers/biothings_studio/
