#!/bin/bash

if [ ! -f /data/biothings/biothings_studio/bin/ssh_host_key ]; then
    ssh-keygen -f /data/biothings/biothings_studio/bin/ssh_host_key
fi

parse_schema() {
	echo $1 | grep '://' | sed -E -e  's,^(.*)://.*,\1,'
}

parse_username() {
	echo $1 | grep '@' | cut -d@ -f1 | sed -E -e 's,.*://(.*):(.*),\1,'
}

parse_password() {
	echo $1 | grep '@' | cut -d@ -f1 | sed -E -e 's,.*://(.*):(.*),\2,'
}

parse_host() {
	local host=$(echo $1 | sed -E -e 's,(.*://)?(.*@)?([^/:]*)(:[0-9]+)?(\/.*)?,\3,')
	if [ -z $host ]; then
		echo localhost
	else
		echo $host
	fi
}

parse_port() {
	local port=$(echo $1 | sed -E -e 's,(.*://)?(.*@)?([^/:]*)(:([0-9]+))?(\/.*)?,\5,')
	if [ -z $port ]; then
		echo 27017
	else
		echo $port
	fi
}

echo src: $SRC_URI $SRC_DB
echo 
echo target: $TARGET_URI $TARGET_DB
echo
echo hub: $HUB_URI $HUB_DB

DATA_SRC_SERVER=$(parse_host $SRC_URI)
DATA_SRC_PORT=$(parse_port $SRC_URI)
# FIXME: handle urlencoded auth
DATA_SRC_SERVER_USERNAME=$(parse_username $SRC_URI)
DATA_SRC_SERVER_PASSWORD=$(parse_password $SRC_URI)

DATA_TARGET_SERVER=$(parse_host $TARGET_URI)
DATA_TARGET_PORT=$(parse_port $TARGET_URI)
DATA_TARGET_SERVER_USERNAME=$(parse_username $TARGET_URI)
DATA_TARGET_SERVER_PASSWORD=$(parse_password $TARGET_URI)

# FIXME: hub support other db backends
hub_schema=$(parse_schema $HUB_URI)


cat > /data/biothings/biothings_studio/config.py << EOF
# DO NOT EDIT THIS CONFIG DIRECTLY
# INSTEAD, SET THE PROPER ENVIRONMENT VARIABLES
# AND THIS CONFIG WILL BE UPDATED AUTOMATICALLY ON CONTAINER STARTUP

from config_studio_hub import *

DATA_ARCHIVE_ROOT = '/data/biothings/datasources'
DATA_PLUGIN_FOLDER = '/data/biothings/plugins'
DATA_UPLOAD_FOLDER = '/data/biothings/dataupload'
DATA_SRC_SERVER = '$DATA_SRC_SERVER'
DATA_SRC_PORT = $DATA_SRC_PORT
DATA_SRC_DATABASE = '$SRC_DB'
DATA_SRC_SERVER_USERNAME = '$DATA_SRC_SERVER_USERNAME'
DATA_SRC_SERVER_PASSWORD = '$DATA_SRC_SERVER_PASSWORD'

DATA_TARGET_SERVER = '$DATA_TARGET_SERVER'
DATA_TARGET_PORT = $DATA_TARGET_PORT
DATA_TARGET_DATABASE = '$TARGET_DB'
DATA_TARGET_SERVER_USERNAME = '$DATA_TARGET_SERVER_USERNAME'
DATA_TARGET_SERVER_PASSWORD = '$DATA_TARGET_SERVER_PASSWORD'

DATA_HUB_DB_DATABASE = '$HUB_DB'

DIFF_PATH = "/data/biothings/diff"

HUB_DB_BACKEND = {
		"module" : "biothings.utils.mongo",
		"uri" : "$HUB_URI",
		}

LOG_FOLDER = "/data/biothings/logs"
logger = setup_default_log("hub", LOG_FOLDER)

RELEASE_PATH = "/data/biothings/release"
CACHE_FOLDER = "/data/biothings/cache"

RUN_DIR = '/data/biothings/run'
CONFIG_READONLY = False

EOF
cat  /data/biothings/biothings_studio/config.py
exec python /data/biothings/biothings_studio/bin/hub.py
