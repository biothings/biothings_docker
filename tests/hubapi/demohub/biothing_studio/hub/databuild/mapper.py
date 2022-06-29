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
