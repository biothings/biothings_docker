################################################################################
# BioThings.Data Dockerfile
################################################################################
# A Dockerfile that contains an nginx server with randomized data

FROM nginx

MAINTAINER Greg Taylor "greg.k.taylor@gmail.com"

# Install the randomized data sets
ADD randomized-dataset-001.gz /usr/share/nginx/html/ConsensusPathDB_human_PPI.gz
ADD randomized-dataset-002.zip /usr/share/nginx/html/BIOGRID-ALL-3.4.154.tab2.zip

# Change directory to the 'html' directory
WORKDIR /usr/share/nginx/html

