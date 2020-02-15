all: api webapp studio4

api_mvcgi:
	cd hubapi/mvcgi && make test

webapp_tutorial:
	cd webapp/tutorial && make test

studio4mygene:
	cd webapp/studio4mygene && make test

studio4myvariant:
	cd webapp/studio4myvariant && make test


api: api_mvcgi
webapp: webapp_tutorial
studio4: studio4mygene studio4myvariant

