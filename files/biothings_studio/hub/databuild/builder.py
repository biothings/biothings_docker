from biothings.hub.databuild.builder import DataBuilder
from biothings.hub.dataload.storage import UpsertStorage
from biothings.utils.mongo import get_target_db, doc_feeder

from biothings_hub.databuild.mapper import LineageMapper

class TaxonomyDataBuilder(DataBuilder):
    def post_merge(self, source_names, batch_size, job_manager):
        # get the lineage mapper
        mapper = LineageMapper(name="lineage")
        # load cache (it's being loaded automatically
        # as it's not part of an upload process
        mapper.load()

        # create a storage to save docs back to merged collection
        db = get_target_db()
        col_name = self.target_backend.target_collection.name
        storage = UpsertStorage(db,col_name)

        for docs in doc_feeder(self.target_backend.target_collection, step=batch_size, inbatch=True):
            docs = mapper.process(docs)
            storage.process(docs,batch_size)

