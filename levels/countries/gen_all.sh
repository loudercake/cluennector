#!/usr/bin/env bash

pip install -r requirements.txt
./download_countries_json.sh
./download_maps.py
./merge_images.sh
./generate_clues.py
./clean.sh
