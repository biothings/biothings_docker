################################################################################
# BioThings.Species Dockerfile
################################################################################
# A Dockerfile that contains biothings.species

FROM biothings.api

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Download the latest version of Biothings.Interactions
#RUN git clone https://github.com/biothings/biothings.species.git /usr/local/biothings.species
ADD biothings.species /usr/local/biothings.species

# Change directory to '/usr/local/biothings.species'
WORKDIR /usr/local/biothings.species

# Install the Docker specific setup files
ADD config.py /usr/local/biothings.species/src/
ADD config_hub.py /usr/local/biothings.species/src/
ADD config_www.py /usr/local/biothings.species/src/

# Install SSH Keys for the image
# - (they can be overwritten when the container is started)
ADD ssh_host_key /usr/local/biothings.species/src/bin/
ADD ssh_host_key.pub /usr/local/biothings.species/src/bin/
ADD biothings.pub /usr/local/biothings.species/src/bin/authorized_keys/

# Setup the biothings.species hub data directory structure
RUN mkdir /tmp/run
RUN mkdir /data
RUN mkdir /data/diff
RUN mkdir /data/logs
RUN mkdir /data/release
RUN mkdir /data/userquery

# Change directory to 'src'
WORKDIR /usr/local/biothings.species/src

# Set Environment variables needed to run the Hub
ENV PYTHONPATH $PYTHONPATH:/usr/local/biothings.species/src

# Run the biothings.species server on container start
CMD python bin/hub.py

