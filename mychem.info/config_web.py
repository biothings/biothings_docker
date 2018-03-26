# -*- coding: utf-8 -*-
from biothings.web.settings.default import *
from web.api.query_builder import ESQueryBuilder
from web.api.query import ESQuery
from web.api.transform import ESResultTransformer
from web.api.handlers import DrugHandler, QueryHandler, MetadataHandler, StatusHandler

# *****************************************************************************
# Elasticsearch variables
# *****************************************************************************
# elasticsearch server transport url
ES_HOST = 'elasticsearch:9200'
# elasticsearch index name
ES_INDEX = 'mydrugs_current'
# elasticsearch document type
ES_DOC_TYPE = 'drug'
# make these smaller for c.biothings
ES_SIZE_CAP = 10
# scrolls are smaller
ES_SCROLL_SIZE = 10

API_VERSION = 'v1'

# *****************************************************************************
# App URL Patterns
# *****************************************************************************
APP_LIST = [
    (r"/status", StatusHandler),
    (r"/metadata/?", MetadataHandler),
    (r"/metadata/fields/?", MetadataHandler),
    (r"/{}/drug/(.+)/?".format(API_VERSION), DrugHandler),
    (r"/{}/drug/?$".format(API_VERSION), DrugHandler),
    (r"/{}/compound/(.+)/?".format(API_VERSION), DrugHandler),
    (r"/{}/compound/?$".format(API_VERSION), DrugHandler),
    (r"/{}/chem/(.+)/?".format(API_VERSION), DrugHandler),
    (r"/{}/chem/?$".format(API_VERSION), DrugHandler),
    (r"/{}/query/?".format(API_VERSION), QueryHandler),
    (r"/{}/metadata/?".format(API_VERSION), MetadataHandler),
    (r"/{}/metadata/fields/?".format(API_VERSION), MetadataHandler),
]

###############################################################################
#   app-specific query builder, query, and result transformer classes
###############################################################################

# *****************************************************************************
# Subclass of biothings.web.api.es.query_builder.ESQueryBuilder to build
# queries for this app
# *****************************************************************************
ES_QUERY_BUILDER = ESQueryBuilder
# *****************************************************************************
# Subclass of biothings.web.api.es.query.ESQuery to execute queries for this app
# *****************************************************************************
ES_QUERY = ESQuery
# *****************************************************************************
# Subclass of biothings.web.api.es.transform.ESResultTransformer to transform
# ES results for this app
# *****************************************************************************
ES_RESULT_TRANSFORMER = ESResultTransformer

GA_ACTION_QUERY_GET = 'query_get'
GA_ACTION_QUERY_POST = 'query_post'
GA_ACTION_ANNOTATION_GET = 'drug_get'
GA_ACTION_ANNOTATION_POST = 'drug_post'
GA_TRACKER_URL = 'c.biothings.io'

ANNOTATION_ID_REGEX_LIST = [(re.compile(r'db[0-9]+', re.I), ['drugbank.drugbank_id','drugbank.accession_number']),
                            (re.compile(r'chembl[0-9]+', re.I), 'chembl.molecule_chembl_id'),
                            (re.compile(r'chebi\:[0-9]+', re.I), 'chebi.chebi_id'),
                            (re.compile(r'cid[0-9]+', re.I), 'pubchem.cid'),
                            (re.compile(r'[A-Z0-9]{10}'), 'unii.unii')]
# make max sizes smaller
QUERY_GET_ES_KWARGS['size']['default'] = 10
ANNOTATION_POST_CONTROL_KWARGS['ids']['max'] = 10
QUERY_POST_CONTROL_KWARGS['q']['max'] = 10

STATUS_CHECK = {
    'id': 'USNINKBPBVKHHZ-CYUUQNCZSA-L', #penicillin
    'index': 'mydrugs_current',
    'doc_type': 'drug'
}

HIPCHAT_MESSAGE_COLOR = 'gray'

JSONLD_CONTEXT_PATH = 'web/context/context.json'
