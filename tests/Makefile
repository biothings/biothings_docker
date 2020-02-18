all: api webapp studio4

info:
	df -h
	ps auxgww

api_mvcgi: info
	cd hubapi/mvcgi && make test

webapp_tutorial: info
	cd webapp/tutorial && make test

studio4mygene: info
	cd webapp/studio4mygene && make test

studio4myvariant: info
	cd webapp/studio4myvariant && make test


api: api_mvcgi
webapp: webapp_tutorial
studio4: studio4mygene studio4myvariant

