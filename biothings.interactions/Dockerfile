################################################################################
# BioThings.Interactions Dockerfile
################################################################################
# A Dockerfile that contains biothings.interactions

FROM biothings.api:0.1.2

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Download the latest version of Biothings.Interactions
RUN git clone https://github.com/biothings/biothings.interactions.git /usr/local/biothings.interactions

# Change directory to '/usr/local/biothings.interactions'
WORKDIR /usr/local/biothings.interactions
# Git Checkout the v0.1.0 tag
RUN git checkout tags/v0.1.2

# Install the Docker specific setup files
ADD config.py /usr/local/biothings.interactions/src/
ADD config_hub.py /usr/local/biothings.interactions/src/
ADD config_www.py /usr/local/biothings.interactions/src/

# Setup the biothings.interactions hub data directory structure
RUN mkdir /data
RUN mkdir /data/diff
RUN mkdir /data/logs
RUN mkdir /data/release
RUN mkdir /data/userquery

# Change directory to 'src'
WORKDIR /usr/local/biothings.interactions/src

# Run the biothings.interactions server on container start
CMD python run_hub.py

