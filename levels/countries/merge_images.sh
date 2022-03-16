#!/usr/bin/env bash

mkdir -p images/
for img in maps/*.png
do
    echo "Generating: images/${img##*/}"
    convert "flags/${img##*/}" "$img" -gravity Center -geometry 196x196+0 -composite -resize 512x512  images/${img##*/}
done
