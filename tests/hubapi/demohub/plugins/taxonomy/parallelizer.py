import glob, os

def newjobs(self):
    files = glob.glob(os.path.join(self.data_folder,"*.txt"))
    self.logger.info("Parallelizing per file: %s" % files)
    return [(f,) for f in files]
