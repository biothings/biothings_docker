import os

import biothings, config
biothings.config_for_app(config)

from config import DATA_ARCHIVE_ROOT
from biothings.hub.dataload.dumper import FTPDumper


class UniprotSpeciesDumper(FTPDumper):

    SRC_NAME = "uniprot_species"
    SRC_ROOT_FOLDER = os.path.join(DATA_ARCHIVE_ROOT, SRC_NAME)
    FTP_HOST = 'ftp_server'
    CWD_DIR = ''
    SUFFIX_ATTR = "timestamp"
    FTP_USER = 'test'
    FTP_PASSWD = 'test'

    SCHEDULE = "0 9 * * *"

    def create_todump_list(self, force=False):
        file_to_dump = "speclist.txt"
        new_localfile = os.path.join(self.new_data_folder,file_to_dump)
        try:
            current_localfile = os.path.join(self.current_data_folder, file_to_dump)
        except TypeError:
            # current data folder doesn't even exist
            current_localfile = new_localfile
        if force or not os.path.exists(current_localfile) or self.remote_is_better(file_to_dump, current_localfile):
            # register new release (will be stored in backend)
            self.to_dump.append({"remote": file_to_dump, "local":new_localfile})
