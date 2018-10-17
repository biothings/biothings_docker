from config_hub import *

DATA_ARCHIVE_ROOT = '/data/biothings_studio'
DATA_PLUGIN_FOLDER = '/data/biothings_studio/plugins'
DATA_SRC_SERVER = 'localhost'
DATA_SRC_PORT = 27017
DATA_SRC_DATABASE = 'biothings_src'
DATA_SRC_SERVER_USERNAME = ''
DATA_SRC_SERVER_PASSWORD = ''

DATA_TARGET_SERVER = 'localhost'
DATA_TARGET_PORT = 27017
DATA_TARGET_DATABASE = 'biothings'
DATA_TARGET_SERVER_USERNAME = ''
DATA_TARGET_SERVER_PASSWORD = ''

DATA_HUB_DB_DATABASE = DATA_SRC_DATABASE # keep _src db as before

DIFF_PATH = os.path.join(DATA_ARCHIVE_ROOT,"diff")

HUB_DB_BACKEND = {
		"module" : "biothings.utils.mongo",
		"uri" : "mongodb://localhost:27017",
		}

LOG_FOLDER = os.path.join(DATA_ARCHIVE_ROOT,'logs')
logger = setup_default_log("hub", LOG_FOLDER)

RELEASE_PATH = os.path.join(DATA_ARCHIVE_ROOT,"release")
CACHE_FOLDER = os.path.join(DATA_ARCHIVE_ROOT,'cache')

RUN_DIR = '/data/run'
