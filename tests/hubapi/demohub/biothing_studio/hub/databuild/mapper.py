import biothings.utils.mongo as mongo
from biothings.hub.databuild.mapper import BaseMapper

from hub.dataload.sources.geneinfo.uploader import GeneInfoUploader


class HasGeneMapper(BaseMapper):

    def __init__(self, *args, **kwargs):
        super(HasGeneMapper,self).__init__(*args,**kwargs)
        self.cache = None

    def load(self):
        if self.cache is None:
            # this is a whole dict containing all taxonomy _ids
            col = mongo.get_src_db()[GeneInfoUploader.name]
            self.cache = [d["_id"] for d in col.find({},{"_id":1})]

    def process(self,docs):
        for doc in docs:
            if doc["_id"] in self.cache:
                doc["has_gene"] = True
            else:
                doc["has_gene"] = False
            yield doc


class LineageMapper(BaseMapper):

    def __init__(self, *args, **kwargs):
        super(LineageMapper,self).__init__(*args,**kwargs)
        self.cache = None

    def load(self):
        if self.cache is None:
            # This must be the name of TaxonomyNodesUploader that defined on the taxomony plugin manifest file.
            # biothings_docker/tests/hubapi/demohub/plugins/taxonomy/manifest.json:9
            col = mongo.get_src_db()['nodes']
            self.cache = {}
            [self.cache.setdefault(d["_id"],d["parent_taxid"]) for d in col.find({},{"parent_taxid":1})]

    def get_lineage(self,doc):
        if "taxid" not in doc or "parent_taxid" not in doc:
            return doc

        if doc['taxid'] == doc['parent_taxid']: #take care of node #1
            # we reached the top of the taxonomy tree
            doc['lineage'] = [doc['taxid']]
            return doc
        # initiate lineage with information we have in the current doc
        lineage = [doc['taxid'], doc['parent_taxid']]
        while lineage[-1] != 1:
            if lineage[-1] in self.cache:
                parent = self.cache[lineage[-1]]
                lineage.append(parent)
            else:
                lineage[-1] = 1
        doc['lineage'] = lineage
        return doc

    def process(self,docs):
        for doc in docs:
            doc = self.get_lineage(doc)
            yield doc
