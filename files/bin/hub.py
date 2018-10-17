#!/usr/bin/env python

import asyncio, asyncssh, sys, os, copy
import concurrent.futures
import multiprocessing_on_dill
concurrent.futures.process.multiprocessing = multiprocessing_on_dill
from functools import partial

from collections import OrderedDict

import config, biothings
biothings.config_for_app(config)

import logging
# shut some mouths...
logging.getLogger("elasticsearch").setLevel(logging.ERROR)
logging.getLogger("urllib3").setLevel(logging.ERROR)
logging.getLogger("requests").setLevel(logging.ERROR)
logging.getLogger("boto").setLevel(logging.ERROR)

logging.info("Hub DB backend: %s" % biothings.config.HUB_DB_BACKEND)
logging.info("Hub database: %s" % biothings.config.DATA_HUB_DB_DATABASE)

from biothings.utils.manager import JobManager
loop = asyncio.get_event_loop()
job_manager = JobManager(loop,num_workers=config.HUB_MAX_WORKERS,
                      num_threads=config.HUB_MAX_THREADS,
                      max_memory_usage=config.HUB_MAX_MEM_USAGE)

import biothings.hub.dataload.uploader as uploader
import biothings.hub.dataload.dumper as dumper
import biothings.hub.dataload.source as source
import biothings.hub.databuild.builder as builder
import biothings.hub.databuild.differ as differ
import biothings.hub.databuild.syncer as syncer
import biothings.hub.dataindex.indexer as indexer
import biothings.hub.datainspect.inspector as inspector
from biothings.hub.api.manager import APIManager
from biothings.utils.hub import schedule, pending, done, CompositeCommand, \
                                start_server, HubShell, CommandDefinition

import hub.dataload.sources

shell = HubShell(job_manager)

# will check every 10 seconds for sources to upload
upload_manager = uploader.UploaderManager(poll_schedule = '* * * * * */10', job_manager=job_manager)
dmanager = dumper.DumperManager(job_manager=job_manager)
from biothings.hub.dataplugin.manager import DataPluginManager
dp_manager = DataPluginManager(job_manager=job_manager)
smanager = source.SourceManager(hub.dataload.sources,dmanager,upload_manager,dp_manager)

dmanager.schedule_all()
upload_manager.poll('upload',lambda doc: shell.launch(partial(upload_manager.upload_src,doc["_id"])))

# deal with 3rdparty datasources
import biothings.hub.dataplugin.assistant as assistant
assistant_manager = assistant.AssistantManager(data_plugin_manager=dp_manager,
                                               dumper_manager=dmanager,
                                               uploader_manager=upload_manager,
                                               job_manager=job_manager)
# register available plugin assitant
assistant_manager.configure()
# load existing plugins
assistant_manager.load()

build_manager = builder.BuilderManager(
        job_manager=job_manager)
build_manager.configure()

diff_manager = differ.DifferManager(job_manager=job_manager)
diff_manager.configure([differ.SelfContainedJsonDiffer,])

inspector = inspector.InspectorManager(upload_manager=upload_manager,
                                       build_manager=build_manager,
                                       job_manager=job_manager)

from biothings.hub.databuild.syncer import ThrottledESJsonDiffSelfContainedSyncer, ESJsonDiffSelfContainedSyncer
sync_manager = syncer.SyncerManager(job_manager=job_manager)
sync_manager.configure(klasses=[ESJsonDiffSelfContainedSyncer])

sync_manager_prod = syncer.SyncerManager(job_manager=job_manager)
sync_manager_prod.configure(klasses=[partial(ThrottledESJsonDiffSelfContainedSyncer,config.MAX_SYNC_WORKERS),])

index_manager = indexer.IndexerManager(job_manager=job_manager)
index_manager.configure(config.ES_CONFIG)

# API manager: used to run API instances from the hub
api_manager = APIManager()

from biothings.utils.hub import HubReloader
reloader = HubReloader(["hub/dataload/sources",config.DATA_PLUGIN_FOLDER],
        [smanager,assistant_manager],
        reload_func=partial(shell.restart,force=True))
reloader.monitor()

# let's glue everything together
managers = {
        "dump_manager" : dmanager,
        "upload_manager" : upload_manager,
        "source_manager" : smanager,
        "build_manager" : build_manager,
        "diff_manager" : diff_manager,
        "index_manager" : index_manager,
        "dataplugin_manager" : dp_manager,
        "assistant_manager" : assistant_manager,
        "inspect_manager" : inspector,
        "sync_manager" : sync_manager,
        "api_manager" : api_manager,
        }
shell.register_managers(managers)

COMMANDS = OrderedDict()
# getting info
COMMANDS["source_info"] = CommandDefinition(command=smanager.get_source,tracked=False)
COMMANDS["status"] = CommandDefinition(command=shell.status,tracked=False)
# dump commands
COMMANDS["dump"] = dmanager.dump_src
COMMANDS["dump_all"] = dmanager.dump_all
# upload commands
COMMANDS["upload"] = upload_manager.upload_src
COMMANDS["upload_all"] = upload_manager.upload_all
# building/merging
COMMANDS["whatsnew"] = CommandDefinition(command=build_manager.whatsnew,tracked=False)
COMMANDS["lsmerge"] = build_manager.list_merge
COMMANDS["rmmerge"] = build_manager.delete_merge
COMMANDS["merge"] = build_manager.merge
COMMANDS["premerge"] = partial(build_manager.merge,steps=["merge","metadata"])
COMMANDS["es_config"] = config.ES_CONFIG
# diff
COMMANDS["diff"] = diff_manager.diff
COMMANDS["report"] = diff_manager.diff_report
COMMANDS["release_note"] = diff_manager.release_note
COMMANDS["publish_diff"] = diff_manager.publish_diff
# indexing commands
COMMANDS["index"] = index_manager.index
COMMANDS["snapshot"] = index_manager.snapshot
COMMANDS["publish_snapshot"] = index_manager.publish_snapshot
# inspector
COMMANDS["inspect"] = inspector.inspect
# data plugins
COMMANDS["register_url"] = partial(assistant_manager.register_url)
COMMANDS["unregister_url"] = partial(assistant_manager.unregister_url)
COMMANDS["dump_plugin"] = dp_manager.dump_src

# admin/advanced
from biothings.utils.jsondiff import make as jsondiff
EXTRA_NS = {
        "dm" : CommandDefinition(command=dmanager,tracked=False),
        "dpm" : CommandDefinition(command=dp_manager,tracked=False),
        "am" : CommandDefinition(command=assistant_manager,tracked=False),
        "um" : CommandDefinition(command=upload_manager,tracked=False),
        "bm" : CommandDefinition(command=build_manager,tracked=False),
        "dim" : CommandDefinition(command=diff_manager,tracked=False),
        "sm" : CommandDefinition(command=sync_manager,tracked=False),
        "im" : CommandDefinition(command=index_manager,tracked=False),
        "jm" : CommandDefinition(command=job_manager,tracked=False),
        "ism" : CommandDefinition(command=inspector,tracked=False),
        "api" : CommandDefinition(command=api_manager,tracked=False),
        "sync" : CommandDefinition(command=sync_manager.sync),
        "loop" : CommandDefinition(command=loop,tracked=False),
        "pqueue" : CommandDefinition(command=job_manager.process_queue,tracked=False),
        "tqueue" : CommandDefinition(command=job_manager.thread_queue,tracked=False),
        "g" : CommandDefinition(command=globals(),tracked=False),
        "sch" : CommandDefinition(command=partial(schedule,loop),tracked=False),
        "top" : CommandDefinition(command=job_manager.top,tracked=False),
        "pending" : CommandDefinition(command=pending,tracked=False),
        "done" : CommandDefinition(command=done,tracked=False),
        # required by API only (just fyi)
        "builds" : CommandDefinition(command=build_manager.build_info,tracked=False),
        "build" : CommandDefinition(command=lambda id: build_manager.build_info(id=id),tracked=False),
        "job_info" : CommandDefinition(command=job_manager.job_info,tracked=False),
        "dump_info" : CommandDefinition(command=dmanager.dump_info,tracked=False),
        "upload_info" : CommandDefinition(command=upload_manager.upload_info,tracked=False),
        "build_config_info" : CommandDefinition(command=build_manager.build_config_info,tracked=False),
        "index_info" : CommandDefinition(command=index_manager.index_info,tracked=False),
        "diff_info" : CommandDefinition(command=diff_manager.diff_info,tracked=False),
        "commands" : CommandDefinition(command=shell.command_info,tracked=False),
        "command" : CommandDefinition(command=lambda id,*args,**kwargs: shell.command_info(id=id,*args,**kwargs),tracked=False),
        "sources" : CommandDefinition(command=smanager.get_sources,tracked=False),
        "source_save_mapping" : CommandDefinition(command=smanager.save_mapping),
        "build_save_mapping" : CommandDefinition(command=build_manager.save_mapping),
        "validate_mapping" : CommandDefinition(command=index_manager.validate_mapping),
        "jsondiff" : CommandDefinition(command=jsondiff,tracked=False),
        "create_build_conf" : CommandDefinition(command=build_manager.create_build_configuration),
        "delete_build_conf" : CommandDefinition(command=build_manager.delete_build_configuration),
        "get_apis" : CommandDefinition(command=api_manager.get_apis,tracked=False),
        "delete_api" : CommandDefinition(command=api_manager.delete_api),
        "create_api" : CommandDefinition(command=api_manager.create_api),
        "start_api" : CommandDefinition(command=api_manager.start_api),
        "stop_api" : api_manager.stop_api,
}

import tornado.web
from biothings.hub.api import generate_api_routes, EndpointDefinition, start_api

API_ENDPOINTS = {
        # extra commands for API
        "builds" : EndpointDefinition(name="builds",method="get"),
        "build" : [EndpointDefinition(method="get",name="build"),
                   EndpointDefinition(method="delete",name="rmmerge"),
                   EndpointDefinition(name="merge",method="put",suffix="new"),
                   EndpointDefinition(name="build_save_mapping",method="put",suffix="mapping"),
                   ],
        "diff" : EndpointDefinition(name="diff",method="put",force_bodyargs=True),
        "job_manager" : EndpointDefinition(name="job_info",method="get"),
        "dump_manager": EndpointDefinition(name="dump_info", method="get"),
        "upload_manager" : EndpointDefinition(name="upload_info",method="get"),
        "build_manager" : EndpointDefinition(name="build_config_info",method="get"),
        "index_manager" : EndpointDefinition(name="index_info",method="get"),
        "diff_manager" : EndpointDefinition(name="diff_info",method="get"),
        "commands" : EndpointDefinition(name="commands",method="get"),
        "command" : EndpointDefinition(name="command",method="get"),
        "sources" : EndpointDefinition(name="sources",method="get"),
        "source" : [EndpointDefinition(name="source_info",method="get"),
                    EndpointDefinition(name="dump",method="put",suffix="dump"),
                    EndpointDefinition(name="upload",method="put",suffix="upload"),
                    EndpointDefinition(name="source_save_mapping",method="put",suffix="mapping")],
        "inspect" : EndpointDefinition(name="inspect",method="put",force_bodyargs=True),
        "dataplugin/register_url" : EndpointDefinition(name="register_url",method="post",force_bodyargs=True),
        "dataplugin/unregister_url" : EndpointDefinition(name="unregister_url",method="delete",force_bodyargs=True),
        "dataplugin" : [EndpointDefinition(name="dump_plugin",method="put",suffix="dump")],
        "jsondiff" : EndpointDefinition(name="jsondiff",method="post",force_bodyargs=True),
        "mapping/validate" : EndpointDefinition(name="validate_mapping",method="post",force_bodyargs=True),
        "buildconf" : [EndpointDefinition(name="create_build_conf",method="post",force_bodyargs=True),
                       EndpointDefinition(name="delete_build_conf",method="delete",force_bodyargs=True)],
        "index" : EndpointDefinition(name="index",method="put",force_bodyargs=True),
        "sync" : EndpointDefinition(name="sync",method="post",force_bodyargs=True),
        "whatsnew" : EndpointDefinition(name="whatsnew",method="get"),
        "status" : EndpointDefinition(name="status",method="get"),
        "api" : [EndpointDefinition(name="start_api",method="put",suffix="start"),
                 EndpointDefinition(name="stop_api",method="put",suffix="stop"),
                 EndpointDefinition(name="delete_api",method="delete",force_bodyargs=True),
                 EndpointDefinition(name="create_api",method="post",force_bodyargs=True)],
        "api/list" : EndpointDefinition(name="get_apis",method="get"),
        "stop" : EndpointDefinition(name="stop",method="put"),
        "restart" : EndpointDefinition(name="restart",method="put"),
        }

shell.set_commands(COMMANDS,EXTRA_NS)

import tornado.platform.asyncio
tornado.platform.asyncio.AsyncIOMainLoop().install()

settings = {'debug': True}
routes = generate_api_routes(shell, API_ENDPOINTS,settings=settings)
# add websocket endpoint
import biothings.hub.api.handlers.ws as ws
import sockjs.tornado
from biothings.utils.hub_db import ChangeWatcher
listener = ws.HubDBListener()
ChangeWatcher.add(listener)
ChangeWatcher.publish()
ws_router = sockjs.tornado.SockJSRouter(partial(ws.WebSocketConnection,listener=listener), '/ws')
routes.extend(ws_router.urls)

# register app into current event loop
app = tornado.web.Application(routes,settings=settings)
EXTRA_NS["app"] = app
app_server = start_api(app,config.HUB_API_PORT)

server = start_server(loop,"BioThings Studio hub",passwords=config.HUB_PASSWD,
                      port=config.HUB_SSH_PORT,shell=shell)

try:
    loop.run_until_complete(server)
except (OSError, asyncssh.Error) as exc:
    sys.exit('Error starting server: ' + str(exc))

loop.run_forever()

