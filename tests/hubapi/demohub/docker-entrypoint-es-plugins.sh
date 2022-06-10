#!/bin/bash

if [ ! -d "/usr/share/elasticsearch/plugins/repository-s3" ]
then
    bin/elasticsearch-plugin install --batch repository-s3 && \
    echo $AWS_ACCESS_KEY | bin/elasticsearch-keystore add --force --stdin s3.client.default.access_key && \
    echo $AWS_SECRET_KEY | bin/elasticsearch-keystore add --force --stdin s3.client.default.secret_key && \
    exec /bin/tini -- /usr/local/bin/docker-entrypoint.sh eswrapper -s
else
    exec /bin/tini -- /usr/local/bin/docker-entrypoint.sh eswrapper -s
fi
