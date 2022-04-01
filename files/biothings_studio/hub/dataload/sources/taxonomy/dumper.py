import os

import biothings, config
biothings.config_for_app(config)

from config import DATA_ARCHIVE_ROOT
from biothings.hub.dataload.dumper import FTPDumper
from biothings.utils.common import untargzall


class TaxonomyDumper(FTPDumper):

    SRC_NAME = "taxonomy"
    SRC_ROOT_FOLDER = os.path.join(DATA_ARCHIVE_ROOT, SRC_NAME)
    FTP_HOST = 'ftp.ncbi.nih.gov'
    CWD_DIR = '/pub/taxonomy'
    SUFFIX_ATTR = "timestamp"

    SCHEDULE = "0 9 * * *"

    def create_todump_list(self, force=False):
        file_to_dump = "taxdump.tar.gz"
        new_localfile = os.path.join(self.new_data_folder,file_to_dump)
        try:
            current_localfile = os.path.join(self.current_data_folder, file_to_dump)
        except TypeError:
            # current data folder doesn't even exist
            current_localfile = new_localfile
        if force or not os.path.exists(current_localfile) or self.remote_is_better(file_to_dump, current_localfile):
            # register new release (will be stored in backend)
            self.to_dump.append({"remote": file_to_dump, "local":new_localfile})

    def post_dump(self, *args, **kwargs):
        untargzall(self.new_data_folder)
