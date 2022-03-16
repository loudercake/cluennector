#!/usr/bin/env python3

import requests
from tqdm import tqdm
from pathlib import Path
import subprocess

from countries import countries, clear_dir


def download(url, filename):
    response = requests.get(url)
    if response.status_code != 200:
        print(f"FAILED TO GET {url}")
        return False
    img_data = response.content
    with open(filename, "wb") as handler:
        handler.write(img_data)
    return True


clear_dir("flags")
print("Downloading countries flags...")
for iso in tqdm(countries):
    url = countries[iso]["flags"]["png"]
    download(url, f"./flags/{iso.lower()}.png")

clear_dir("maps")
print("Downloading countries svg maps...")
for iso in tqdm(countries):
    url = f"https://raw.githubusercontent.com/djaiss/mapsicon/master/all/{iso.lower()}/vector.svg"
    filename = f"./maps/{iso.lower()}"
    if download(url, filename + ".svg"):
        subprocess.check_call(f"convert -fuzz 50% -fill 'rgb(64, 255, 64)' -opaque 'rgb(0, 0, 0)' -background none {filename}.svg {filename}_map.png", shell=True)
        subprocess.check_call(f"convert {filename}_map.png -alpha on -channel a -evaluate multiply 0.75 +channel {filename}.png", shell=True)
