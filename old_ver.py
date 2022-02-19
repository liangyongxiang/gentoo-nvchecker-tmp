#!/usr/bin/env python3
import portage
import json

p = portage.db[portage.root]["porttree"].dbapi
with open('pkgs.txt') as f:
    old_ver = {}
    for package in f.read().splitlines():
        bestmatch = p.xmatch("bestmatch-visible", package)
        if bestmatch:
            category, name, version, revision = portage.catpkgsplit(bestmatch)
            old_ver[name] = version

with open('old_ver.json', 'w') as f:
        json.dump(old_ver, f, indent=4)

