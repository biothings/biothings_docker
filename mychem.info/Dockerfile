################################################################################
# BioThings.Species Dockerfile
################################################################################
# A Dockerfile that contains mychem.info

FROM python

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Download the latest version of Biothings.Interactions
#RUN git clone https://github.com/biothings/mychem.info.git /usr/local/mychem.info
ADD mychem.info /usr/local/mychem.info

# Change directory to '/usr/local/mychem.info'
WORKDIR /usr/local/mychem.info

# Install python libraries
RUN pip install -r requirements_hub.txt
RUN pip install -r requirements_web.txt

# Install the Docker specific setup files
ADD config.py /usr/local/mychem.info/src/
ADD config_hub.py /usr/local/mychem.info/src/
ADD config_web.py /usr/local/mychem.info/src/

# Install SSH Keys for the image
# - (they can be overwritten when the container is started)
ADD ssh_host_key /usr/local/mychem.info/src/bin/
ADD ssh_host_key.pub /usr/local/mychem.info/src/bin/

# Setup the mychem.info hub data directory structure
RUN mkdir /tmp/run
RUN mkdir /data
RUN mkdir /data/diff
RUN mkdir /data/logs
RUN mkdir /data/release
RUN mkdir /data/userquery

# Change directory to 'src'
WORKDIR /usr/local/mychem.info/src

# Set Environment variables needed to run the Hub
ENV PYTHONPATH $PYTHONPATH:/usr/local/mychem.info/src

# Run the mychem.info server on container start
CMD python bin/hub.py

