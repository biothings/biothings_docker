# Biothings.docker Randomized Datasets
### Maintainer:  Greg Taylor (greg.k.taylor@gmail.com)

The following datafiles can be downloaded and them randomized
using the included script.  A small amount of data is then saved
in the repository for convenience.  The orignial dataset headers
are also preserved manually.

## Installation
### Build the biothings.data Docker image
```
docker build --no-cache -t biothings.data .
```

## Background
### How much randomized data?

An arbitrary decision was made to keep 1000 lines from each
randomized dataset.

### Randomized Dataset 1 - ConsensusPathDB
```
curl -o http://cpdb.molgen.mpg.de/download/ConsensusPathDB_human_PPI.gz
gunzip ConsensusPathDB_human_PPI.gz
python randomize-data.py ConsensusPathDB_human_PPI > randomized-dataset-001
rm ConsensusPathDB_human_PPI
gzip randomized-dataset-001
```

### Randomized Dataset 2 - BioGRID
```
curl -o https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.4.154/BIOGRID-ALL-3.4.154.tab2.zip
unzip BIOGRID-ALL-3.4.154.tab2.zip
rm BIOGRID-ALL-3.4.154.tab2.zip
python randomize-data.py BIOGRID-ALL-3.4.154.tab2.txt > randomized-dataset-002
rm BIOGRID-ALL-3.4.154.tab2.txt
zip randomized-dataset-002.zip randomized-dataset-002
rm randomized-dataset-002
```



