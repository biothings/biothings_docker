all: test

pull:
	docker pull biothings/biothings-studio:unstable

kill:
	-docker kill test_studio
	sleep 5
	while docker ps | grep test_studio; do sleep 1; done

run: docker_kill
	docker run --rm --name test_studio -p 8080:8080 -p 7080:7080 -p 8000:8000 -d biothings/biothings-studio:unstable

wait:
	while ! curl localhost:7080; do echo waiting for hub api to run; sleep 5; done

test: pull run wait
	HUB_API_HOST=http://localhost:7080 py.test hubapi/mvcgi

