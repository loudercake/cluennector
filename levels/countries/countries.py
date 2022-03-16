#!/usr/bin/env python3

import json
from pathlib import Path
from shutil import rmtree

_countries = json.load(open("./all_countries.json"))
countries = {c["cca2"]: c for c in _countries}
countries_cca3 = {c["cca3"]: c for c in _countries}

def clear_dir(dir):
    print(f"whipping maps {dir}")
    rmtree(dir, ignore_errors=True)
    Path(dir).mkdir(exist_ok=True)

if __name__ == '__main__':
    print([p.stem for p in Path("./images/").glob("*.png")])
