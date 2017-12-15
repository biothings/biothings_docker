################################################################################
# BioThings.Interactions Dockerfile
################################################################################
# A Dockerfile that contains biothings.interactions

FROM biothings.api

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Download the latest version of Biothings.Interactions
# RUN git clone https://github.com/biothings/biothings.interactions.git /usr/local/biothings.interactions

# Add the latest version of Biothings.Interactions
ADD biothings.interactions /usr/local/biothings.interactions
RUN pip install /usr/local/biothings.interactions

# Change directory to '/usr/local/biothings.interactions'
WORKDIR /usr/local/biothings.interactions

# Git Checkout the v0.1.0 tag
# RUN git checkout tags/v0.1.2

# Install the Docker specific setup files
ADD config.py /usr/local/biothings.interactions/biointeract/
ADD config_hub.py /usr/local/biothings.interactions/biointeract/
ADD config_www.py /usr/local/biothings.interactions/biointeract/

# Install keys
ADD ssh_host_key /usr/local/biothings.interactions/biointeract/bin
ADD ssh_host_key.pub /usr/local/biothings.interactions/biointeract/bin
ADD biothings.pub /usr/local/biothings.interactions/biointeract/bin/authorized_keys/

# Setup the biothings.interactions hub data directory structure
RUN mkdir /data
RUN mkdir /data/diff
RUN mkdir /data/logs
RUN mkdir /data/release
RUN mkdir /data/userquery

# Change directory to 'biointeract'
WORKDIR /usr/local/biothings.interactions/biointeract

# Set Environment variables needed to run the Hub
ENV PYTHONPATH $PYTHONPATH:/usr/local/biothings.interactions/biointeract

# Run the biothings.interactions server on container start
CMD python bin/hub.py
