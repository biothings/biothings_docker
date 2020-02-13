all: apitest webapptest

docker_pull:
	docker pull biothings/biothings-studio:unstable
docker_pull_studio4mygene:
	docker pull biothings/studio4mygene:unstable

docker_kill:
	-docker kill test_studio
	sleep 5
	while docker ps | grep test_studio; do sleep 1; done
docker_run: docker_kill
	docker run --rm --name test_studio -p 8080:8080 -p 7080:7080 -p 8000:8000 -d biothings/biothings-studio:unstable
docker_run_studio4mygene: docker_kill
	docker run --rm --name test_studio -p 8080:8080 -p 7080:7080 -p 8000:8000 -d biothings/studio4mygene:unstable
docker_wait:
	while ! curl localhost:7080; do echo waiting for hub api to run; sleep 5; done

npm_install:
	cd webapp/tutorial && npm install

test_api_mvcgi: docker_pull docker_run docker_wait
	HUB_API_HOST=http://localhost:7080 py.test hubapi/mvcgi

test_webapp_tutorial: docker_pull npm_install docker_run docker_wait
	# npx is the launcher, not installed globally (no sudo) so use local path explicitely
	cd webapp/tutorial && ./node_modules/.bin/npx codeceptjs run --steps -o '{ "helpers": {"Puppeteer": {"show": false}}}'

test_studio4mygene: docker_pull_studio4mygene npm_install docker_run_studio4mygene docker_wait
	cd webapp/studio4mygene && ./node_modules/.bin/npx codeceptjs run --steps -o '{ "helpers": {"Puppeteer": {"show": false}}}'


apitest: test_api_mvcgi
webapptest: test_webapp_tutorial test_studio4mygene

