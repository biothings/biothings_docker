# biothings.docker
## BioThings Docker containers
### Maintainer:  Greg Taylor (greg.k.taylor@gmail.com)

This repository contains files needed to build docker images and
setup docker hosts using these images.

### biothings.api
Build a docker image containing the docker.api package and all required
python packages.

### biothings.data
Randomize data files and setup an nginx-like continer for serving these
files on a docker host.

### biothings.interactions
A Dockerfile for the biothings.interactions application together with a
docker-compose file needed to run all required services.
