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
