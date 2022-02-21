#!/usr/bin/env python3
import portage
import json

def main(pkgs_file, version_file)
    p = portage.db[portage.root]["porttree"].dbapi
    with open(pkgs_file) as f:
        old_ver = {}
        for package in f.read().splitlines():
            bestmatch = p.xmatch("bestmatch-visible", package)
            if bestmatch:
                category, name, version, revision = portage.catpkgsplit(bestmatch)
                old_ver[name] = version

    with open(version_file, 'w') as f:
            json.dump(old_ver, f, indent=4)

if __name__ == '__main__':
    main(sys.args[1], sys.args[2])
