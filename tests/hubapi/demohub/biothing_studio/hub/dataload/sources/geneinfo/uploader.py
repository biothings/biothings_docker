import os

import biothings.hub.dataload.uploader as uploader
import biothings.hub.dataload.storage as storage
from .parser import parse_geneinfo_taxid

class GeneInfoUploader(uploader.BaseSourceUploader):

    storage_class = storage.IgnoreDuplicatedStorage

    name = "geneinfo"

    def load_data(self,data_folder):
        gene_file = os.path.join(data_folder,"gene_info")
        self.logger.info("Load data from file '%s'" % gene_file)
        return parse_geneinfo_taxid(open(gene_file))

    def post_update_data(self, steps, force, batch_size, job_manager):
        from biothings.hub.databuild.builder import set_pending_to_build
        # trigger a merge/build
        set_pending_to_build()

    @classmethod
    def get_mapping(klass):
        return {
                "has_gene": {
                    "type": "boolean"
                    },
                }
