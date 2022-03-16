#!/usr/bin/env python3

from collections import OrderedDict
from pathlib import Path

from godot_parser import (ExtResource, GDExtResourceSection, GDResource,
                          GDResourceSection, GDSection, GDSectionHeader,
                          Vector2, load)
from tqdm import tqdm

from countries import countries, countries_cca3, clear_dir

clear_dir("clues")

for iso, country in tqdm(countries.items()):
    if "borders" not in country:
        next = []
    else:
        area = country["area"]
        next = [ct for ct in country["borders"] if countries_cca3[ct]["area"] < area]
    description = f"{country['name']['common']}"
    texture = f"images/{iso.lower()}.png"
    # if texture file does not exists continue
    if not Path(texture).exists():
        print(f"SKIPPING {texture} does not exists")
        continue
    texture = f"res://levels/countries/{texture}"
    # if texture file does not exists continue
    r = load("clue.tres.base")
    r.add_ext_resource(texture, "Texture")
    corrected_next = []
    for ct in next:
        nclue = f"{countries_cca3[ct]['cca2'].lower()}"
        if Path(f"images/{nclue}.png").exists():
            r.add_ext_resource(
                f"res://levels/countries/clues/{nclue}.tres",
                "Resource",
            )
            corrected_next.append(ct)
        else:
            print(f"SKIPPING DANGLING Reference of {iso}: ", ct)
    s = GDSection(GDSectionHeader("resource"))
    s.properties = OrderedDict(
        {
            "script": ExtResource(1),
            "description": description,
            "texture": ExtResource(2),
            "next": [ExtResource(i) for i in range(3, len(corrected_next) + 3)],
            "pos": Vector2(-1, -1),
        }
    )
    r.add_section(s)
    # print(r)
    r.write(f"./clues/{iso.lower()}.tres")

print("Don't forget to run ./clean.sh before opening godot!")
