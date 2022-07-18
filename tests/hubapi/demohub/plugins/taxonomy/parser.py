from itertools import groupby
from collections import defaultdict

import os
import json


def get_allowed_tax_ids():
    tax_ids_path = os.path.join(os.path.dirname(__file__), "allowed_tax_ids.json")
    try:
        with open(tax_ids_path) as f:
            return json.load(f)
    except Exception as e:
        return


def parse_refseq_names(data_folder):
    '''
    names_file is a file-like object yielding 'names.dmp' from taxdump.tar.gz
    '''
    names_file_path = os.path.join(data_folder, "names.dmp")
    names_file = open(names_file_path)
    allowed_tax_ids = get_allowed_tax_ids()
    #Collapse all the following fields into "synonyms"
    other_names = ["acronym","anamorph","blast name","equivalent name","genbank acronym","genbank anamorph",
    "genbank synonym","includes","misnomer","misspelling","synonym","teleomorph"]
    # keep separate: "common name", "genbank common name"
    print(names_file)
    names_gb = groupby(names_file, lambda x: x[:x.index('\t')])
    for taxid, entry in names_gb:
        if allowed_tax_ids and taxid not in allowed_tax_ids:
            continue

        d = defaultdict(list)
        d['taxid'] = int(taxid)
        d['_id'] = taxid
        for line in entry:
            split_line = line.split('\t')
            field = split_line[6]
            value = split_line[2].lower()
            if field == 'scientific name':
                d['scientific_name'] = value #only one per entry. Store as str (not in a list)
            elif field in other_names:
                d['other_names'].append(value) #always a list
            elif field == "common name":
                if d['common_name'] == []: #empty
                    d['common_name'] = value # set as string
                elif type(d['common_name']) == str: # has a single entry
                    d['common_name'] = [d['common_name']] #make it a list
                    d['common_name'].append(value)
                else:
                    d['common_name'].append(value)
            elif field == "genbank common name":
                if d['genbank_common_name'] == []: #empty
                    d['genbank_common_name'] = value # set as string
                elif type(d['genbank_common_name']) == str: # has a single entry
                    d['genbank_common_name'] = [d['genbank_common_name']] #make it a list
                    d['genbank_common_name'].append(value)
                else:
                    d['genbank_common_name'].append(value)
            else:
                d[field].append(value)
        yield dict(d)


def parse_refseq_nodes(data_folder):
    '''
    nodes_file is a file-like object yielding 'nodes.dmp' from taxdump.tar.gz
    '''
    allowed_tax_ids = get_allowed_tax_ids()
    nodes_file_apth = os.path.join(data_folder,"nodes.dmp")
    nodes_file = open(nodes_file_apth)
    for line in nodes_file:
        d = dict()
        split_line = line.split('\t')
        taxid = split_line[0]

        if allowed_tax_ids and taxid not in allowed_tax_ids:
            continue

        d["_id"] = taxid
        d['taxid'] = int(taxid)
        d['parent_taxid'] = int(split_line[2])
        d['rank'] = split_line[4]
        yield d


def custom_nodes_mapping(klass):
    return {
        "rank": {
            "type": "text"
            },
        "taxid": {
            "copy_to" : ["all"],
            "type": "long"
            },
        "parent_taxid": {
            "type": "long"
            },
        }


def custon_names_mapping(klass):
    return {
        "scientific_name": {
            "copy_to" : ["all"],
            "type": "text"
            },
        "common_name": {
            "copy_to" : ["all"],
            "type": "text"
            },
        "genbank_common_name": {
            "type": "text"
            }
        }
