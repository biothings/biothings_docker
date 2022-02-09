# Building an image
docker build --force-rm -t biothings_studio .
# run image
docker run --rm --name studio -p 8000:8000 -p 8080:8080 -p 7022:7022 -p 7080:7080 -d biothings_studio

# or, using Makefile
make biothings_studio       # build image
make biothings_studio save  # save image

## Other Targets:

prerequisite:  docker, make

- `make studio4mygene`
- `make studio4myvariant`
- `make studio4mychem`


# Testing
- Follow tutorial http://docs.biothings.io/en/latest/tutorial/studio.html
  (using https://github.com/sirloon/mvcgi datasource). Tests the whole process
- https://github.com/sirloon/gwascatalog for dumper custom release
- https://github.com/sirloon/FIRE for parallelization

Tests are located in the `tests` directory.


# If your newly built container does not run

Contrary to usual docker containers that are single purpose, this container
runs multiple applications, for historical and compatibility reasons.

In essence, it runs Nginx, MongoDB, and Elasticsearch in the background, and then switches
to the `biothings` user and starts up tmux. Inside tmux, the BioThings Hub is run.

If something went wrong and you need to figure out what's going on, here are a few
tips:

1. You can use `docker exec -it <CONTAINER> /bin/bash` to get inside the container, or
you can elect not to run the container in the background. This way you get a root shell
prompt so you can inspect things.

2. Usually Nginx, ES and MongoDB don't tend to break. So once you have the root prompt, 
you can run `su - biothings` to switch user, and then attach to the running tmux session
to figure out what actually went wrong with BioThings Hub.

3. Usually it's because a dependency has changed, in this case make up your mind whether 
you want to pin the version of the dependency or upgrade BioThings to be compatible with
the new version.

4. Or BioThings SDK was changed in a way that the old default configuration files are no
longer compatible. In this case just fix the config files. Some of them come from 
Ansible making patches here and there but most of the file should be what you see in the
repos.
