#!/usr/bin/env python

import config, biothings, logging
biothings.config_for_app(config)

logging.info("Hub DB backend: %s" % biothings.config.HUB_DB_BACKEND)
logging.info("Hub database: %s" % biothings.config.DATA_HUB_DB_DATABASE)

from biothings.hub import HubServer
import hub.dataload.sources
server = HubServer(hub.dataload.sources,name="BioThings Studio")
server.start()
