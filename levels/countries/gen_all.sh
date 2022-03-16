#!/usr/bin/env bash

if ! command -v convert >/dev/null 2>&1; then
    echo "convert command not found"
    exit 1
fi
pip install -r requirements.txt
./download_countries_json.sh
./download_maps.py
./merge_images.sh
./generate_clues.py
./clean.sh
