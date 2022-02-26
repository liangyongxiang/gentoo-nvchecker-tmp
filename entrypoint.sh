#!/bin/sh -l

set -xeuo pipefail


echo "::group::overlay sync"
repo_name=$(cat "${GITHUB_WORKSPACE}/profiles/repo_name")
eselect repository add $repo_name git "file://${GITHUB_WORKSPACE}"
emerge --sync $repo_name
eix-update
echo "::endgroup::"

echo "::group::package version"
pkgs=$(EIX_LIMIT=0 NAMEVERSION="<category>/<name>-<version>\n" eix --pure-packages --in-overlay "$repo_name" --format '<bestversion:NAMEVERSION>')
pkgs=$(qatom -F "\"%{PN}\": \"%{PV}\"," $pkgs) # remove revision
pkgs="{ ${pkgs::-1} }"
echo "$pkgs" | hexdump -C
echo "$pkgs" > old_ver.json
echo "::endgroup::"

echo "::group::nvchecker"
cp "${GITHUB_WORKSPACE}/.github/workflows/overlay.toml" ./
wc overlay.toml keyfile.toml
nvchecker --file overlay.toml --keyfile keyfile.toml
wc old_ver.json new_ver.json
cat new_ver.json old_ver.json

bumps="$(nvcmp --file overlay.toml --json)"
hexdump -C <<< "$bumps"
echo "::set-output name=bumps::${bumps}"
echo "::endgroup::"

