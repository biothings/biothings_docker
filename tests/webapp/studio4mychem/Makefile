all: test

pull:
	docker pull biothings/studio4mychem:unstable

kill:
	-docker kill test_studio
	sleep 5
	while docker ps | grep test_studio; do sleep 1; done

run: kill pull
	docker run --rm --name test_studio -p 8080:8080 -p 7080:7080 -p 8000:8000 -d biothings/studio4mychem:unstable

wait:
	while ! curl localhost:7080; do echo waiting for hub api to run; sleep 5; done

test: run wait
	npm install
	# first we build the API from scratch
	./node_modules/.bin/npx codeceptjs run --steps -o '{ "helpers": {"Puppeteer": {"show": false}}}'
	# then we test it using tavern
	BT_API_HOST=http://localhost:8000 py.test test_studio4mychem_api.tavern.yml

