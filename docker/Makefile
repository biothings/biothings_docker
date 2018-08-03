# make studio
# make studio save
# makz studio sends3

biothings_studio:
	docker build --force-rm \
    --build-arg STUDIO_VERSION=master \
    --build-arg BIOTHINGS_VERSION=master \
    -t biothings_studio:$$(git branch | grep ^\* | sed "s#\* ##") .

containers:
	-mkdir containers

save: containers
	$(eval CONTAINER := $(firstword $(MAKECMDGOALS)))
	docker save $(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##") > containers/$(CONTAINER):$$(git branch | grep ^\* | sed "s#\* ##").docker$ 

sends3:
	$(eval CONTAINERFILE := $(firstword $(MAKECMDGOALS)))
	#aws s3 cp $(CONTAINERFILE) s3://biothings-containers/biothings_studio/
	aws s3 cp containers/$(CONTAINERFILE):$$(git branch | grep ^\* | sed "s#\* ##").docker s3://biothings-containers/biothings_studio/
