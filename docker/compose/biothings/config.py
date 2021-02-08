from config_studio_hub import *

DATA_ARCHIVE_ROOT = '/data/biothings/datasources'
DATA_PLUGIN_FOLDER = '/data/biothings/plugins'
DATA_UPLOAD_FOLDER = '/data/biothings/dataupload'
DATA_SRC_SERVER = 'mongodb'
DATA_SRC_PORT = 27017
DATA_SRC_DATABASE = 'biothings_src'
DATA_SRC_SERVER_USERNAME = ''
DATA_SRC_SERVER_PASSWORD = ''

DATA_TARGET_SERVER = 'mongodb'
DATA_TARGET_PORT = 27017
DATA_TARGET_DATABASE = 'biothings'
DATA_TARGET_SERVER_USERNAME = ''
DATA_TARGET_SERVER_PASSWORD = ''

DATA_HUB_DB_DATABASE = DATA_SRC_DATABASE # keep _src db as before

DIFF_PATH = "/data/biothings/diff"

HUB_DB_BACKEND = {
		"module" : "biothings.utils.mongo",
		"uri" : "mongodb://mongodb:27017",
		}

LOG_FOLDER = "/data/biothings/logs"
logger = setup_default_log("hub", LOG_FOLDER)

RELEASE_PATH = "/data/biothings/release"
CACHE_FOLDER = "/data/biothings/cache"

RUN_DIR = '/data/biothings/run'
CONFIG_READONLY = False
