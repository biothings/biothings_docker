# Biothings.species docker container
### Maintainer:  Greg Taylor (greg.k.taylor@gmail.com)

Build a docker image containing the docker.species package.
Setup a development docker host running all required docker services.

## Installation

### Copy the biothings.species directory to this local directory

### Build the biothings.species Docker image
```
docker build --no-cache -t biothings.species .
```

### Run the biothings.species evaluation environment

Before you run the docker-compose command you should generate a ssh_host_key file with
`ssh-keygen -P '' -f ssh_host_key`.  This key file will be mounted into the correct location when
the collection of containers is started.

```
docker-compose -f docker-compose.yml up
```

The following docker containers are started:

- biothings.data - an nginx server containing randomized data
- mongodb - the mongodb server running version 3.2
- elasticsearch - the ElasticSearch server running version 5.6.4
- biothings.species - the server built by the Dockerfile in this directory

