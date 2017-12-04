################################################################################
# BioThings Dockerfile
################################################################################
# A Dockerfile that contains BioThings.api and the required python dependencies

FROM python

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Download the latest version of Biothings.api
RUN mkdir biothings.api
RUN git clone --branch v0.1.2 https://github.com/greg-k-taylor/biothings.api.git /usr/local/biothings.api

# Install the Biothings.api required pip libraries
WORKDIR /usr/local/biothings.api
RUN pip install -r requirements.txt
RUN python setup.py install

