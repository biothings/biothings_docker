# -*- coding: utf-8 -*-
# *****************************************************************************
# Elasticsearch variables
# *****************************************************************************
# elasticsearch server transport url
ES_HOST = 'elasticsearch:9200'
# elasticsearch index name
ES_INDEX_NAME = 'mydrugs_current'
# elasticsearch document type
ES_DOC_TYPE = 'drug'
# Only these options are passed to the elasticsearch query from kwargs
ALLOWED_OPTIONS = ['_source', 'start', 'from_', 'size', 'fields',
                   'sort', 'explain', 'version', 'facets', 'fetch_all']
ES_SCROLL_TIME = '1m'
ES_SCROLL_SIZE = 1000
ES_SIZE_CAP = 1000
# This is the module for loading the esq variable in handlers
ES_QUERY_MODULE = 'api.es'

# *****************************************************************************
# Google Analytics Settings
# *****************************************************************************
# Google Analytics Account ID
GA_ACCOUNT = ''
# Turn this to True to start google analytics tracking
GA_RUN_IN_PROD = False

# 'category' in google analytics event object
GA_EVENT_CATEGORY = 'v1_api'
# 'action' for get request in google analytics event object
GA_EVENT_GET_ACTION = 'get'
# 'action' for post request in google analytics event object
GA_EVENT_POST_ACTION = 'post'
# url for google analytics tracker
GA_TRACKER_URL = 'MyDrugs.info'

# *****************************************************************************
# URL settings
# *****************************************************************************
# For URL stuff
ANNOTATION_ENDPOINT = 'drug'
QUERY_ENDPOINT = 'query'
API_VERSION = 'v1'
# TODO Fill in a status id here
STATUS_CHECK_ID = ''
# Path to a file containing a json object with information about elasticsearch fields
FIELD_NOTES_PATH = ''
# Path to a file containing a json object with the json-ld context information
JSONLD_CONTEXT_PATH = ''

DATA_SRC_SERVER = 'mongodb'
DATA_SRC_PORT = 27017
DATA_SRC_DATABASE = 'mychem_src'
DATA_SRC_SERVER_USERNAME = ''
DATA_SRC_SERVER_PASSWORD = ''

DATA_TARGET_SERVER = 'mongodb'
DATA_TARGET_PORT = 27017
DATA_TARGET_DATABASE = 'mychem_target'
DATA_TARGET_SERVER_USERNAME = ''
DATA_TARGET_SERVER_PASSWORD = ''

# DATA_ARCHIVE_ROOT = '/path/to/data/folder'
DATA_ARCHIVE_ROOT = '/data'
import os
DIFF_PATH = os.path.join(DATA_ARCHIVE_ROOT,"diff")

from config_hub import *
from config_web import *

