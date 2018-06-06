studio:
	docker build --force-rm --build-arg STUDIO_VERSION=master --build-arg BIOTHINGS_VERSION=master -t biothings_studio .

containers:
	-mkdir containers

save: containers
	$(eval CONTAINER := $(firstword $(MAKECMDGOALS)))
	docker save $(CONTAINER) > containers/$(CONTAINER).docker

sends3:
	$(eval CONTAINERFILE := $(firstword $(MAKECMDGOALS)))
	# must be some easier way...
	$(eval S3FOLDER := $(subst containers/,,$(CONTAINERFILE)))
	$(eval S3FOLDER := $(subst .docker,,$(S3FOLDER)))
	echo $(CONTAINERFILE)
	aws s3 cp $(CONTAINERFILE) s3://biothings-containers/biothings_studio/
