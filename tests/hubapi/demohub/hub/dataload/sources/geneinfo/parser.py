import json
import os

from ..utils import get_allowed_tax_ids


def parse_geneinfo_taxid(fileh):
    allowed_tax_ids = get_allowed_tax_ids()

    for line in fileh:
        if line.startswith("#"):
            # skip header
            continue

        taxid = line.split("\t")[0]
        if allowed_tax_ids and taxid not in allowed_tax_ids:
            continue
    
        yield {"_id" : taxid}
