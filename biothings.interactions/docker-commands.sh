#
# Draft commands to setup a biothings.interactions development environment
#

# Start the mongodb container
docker pull mongo:3.2
docker run -p 27017:27017 --name mongodb -d mongo:3.2

# Start the elasticsearch container
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.6.4
docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" --name es docker.elastic.co/elasticsearch/elasticsearch:5.6.4

# Run the biothings.interactions container linking to the mongodb container
docker run -it --link mongodb:mongodb --link es:es biothings.interactions bash

