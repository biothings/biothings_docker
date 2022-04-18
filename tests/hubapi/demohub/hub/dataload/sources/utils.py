import os
import json


def get_allowed_tax_ids():
    tax_ids_path = os.path.join(os.path.dirname(__file__), "allowed_tax_ids.json")
    try:
        with open(tax_ids_path) as f:
            return json.load(f)
    except Exception as e:
        return
