# BioThings Docker

## Build complete BioThings Studio + Hub
1. `docker compose build`
2. `docker compose up`
3. Go to `http://localhost:8080/` for Biothings Studio
4. Connect to `http://localhost:7080` for local Biothings Hub

## Build BioThings Studio only
1. `docker compose build biothings-studio-webapp`
2. `docker compose up biothings-studio-webapp`
3. Go to `http://localhost:8080/` for Biothings Studio

## Build API Studio
1. `docker compose build --build-arg API_NAME=mygene.info --build-arg API_VERSION=master`  
  Other targets: 
    - `myvariant.info`
    - `mychem.info`
    - `mydisease.info`
    - `mygeneset.info`
2. `docker compose up`
3. Go to `http://localhost:8080/` for Biothings Studio
4. Connect to `http://localhost:7080` for local Biothings Hub

## Connect to remote mongodb/elasticsearch hosts
1. Uncomment the `extra_hosts` sections in `docker-compose.yml` and add your hosts in the format "hostname:ip"
2. Set the `MONGO_HOST` and `ES_HOST` args in `docker-compose.yml` to the hostnames you added in step 1
3. Build and run the container as usual


## Biothings Studio Architecture 
- Biothings Studio Webapp
  - Port: 8080
  - Connects to: Biothings Hub

- Biothings Hub
  - Ports: 7022, 7080
  - Connects to: MongoDB, Elasticsearch

- MongoDB
  - Port: 27017

- Elasticsearch
  - Port: 9200

- Cerebro
  - Port: 9000
  - Connects to: Elasticsearch