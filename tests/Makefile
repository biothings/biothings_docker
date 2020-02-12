all: apitest webapptest

docker_pull:
	docker pull biothings/biothings-studio:unstable

docker_run:
	-docker kill test_studio
	sleep 5
	while docker ps | grep test_studio; do sleep 1; done
	docker run --rm --name test_studio -p 8080:8080 -p 7080:7080 -p 8000:8000 -d biothings/biothings-studio:unstable
	while ! curl localhost:7080; do echo waiting for hub api to run; sleep 5; done

npm_install:
	npm install webapp/tutorial

test_api_mvcgi: docker_pull docker_run
	HUB_API_HOST=http://localhost:7080 py.test hubapi/mvcgi

test_webapp_tutorial: docker_pull npm_install docker_run
	# npx is the launcher, not installed globally (no sudo) so use local path explicitely
	cd webapp/tutorial && ~/node_modules/.bin/npx codeceptjs run --steps -o '{ "helpers": {"Puppeteer": {"show": false}}}'


apitest: test_api_mvcgi
webapptest: test_webapp_tutorial

