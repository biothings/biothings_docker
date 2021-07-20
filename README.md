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
- Follow tutorial http://docs.biothings.io/en/latest/doc/studio_tutorial.html
  (using https://github.com/sirloon/mvcgi datasource). Tests the whole process
- https://github.com/sirloon/gwascatalog for dumper custom release
- https://github.com/sirloon/FIRE for parallelization
