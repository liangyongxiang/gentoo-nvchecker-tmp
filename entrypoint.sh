#!/bin/sh -l

set -xeuo pipefail

export PATH="/root/.local/bin:$PATH"
export PATH="/github/home/.local/bin:$PATH"

proc_num=$(nproc)

echo "::group::prepare"
echo -e "[keys]\ngithub = \"${INPUT_GITHUB_TOKEN}\"" > keyfile.toml
echo "::group::update make.conf"
cat <<EOT >> /etc/portage/make.conf
EMERGE_DEFAULT_OPTS="${INPUT_EMERGE_DEFAULT_OPTS} --jobs $proc_num --load-average $proc_num"
MAKEOPTS="-j$proc_num"
PORTAGE_TMPDIR="${INPUT_PORTAGE_TMPDIR}"
FEATURES="${INPUT_FEATURES}"
ACCEPT_KEYWORDS="${INPUT_ACCEPT_KEYWORDS}"
ACCEPT_LICENSE="${INPUT_ACCEPT_LICENSE}"
EOT
cat /etc/portage/make.conf
echo "::endgroup::"

echo "::group::update main tree and install depends"
emerge-webrsync
eselect news read all > /dev/null
emerge app-eselect/eselect-repository app-portage/eix dev-python/pip
echo "::endgroup::"

echo "::group::overlay sync"
repo_name=$(cat "${GITHUB_WORKSPACE}/profiles/repo_name")
eselect repository add $repo_name git "file://${GITHUB_WORKSPACE}"
emerge --sync $repo_name
egencache --jobs=$proc_num --update --repo $repo_name
echo "::endgroup::"

echo "::group::install nvchecker"
pip install --user nvchecker
nvchecker --version
echo "::endgroup::"

echo "::group::package version"
eix-update
EIX_LIMIT=0 eix -# --in-overlay "$repo_name" | grep -Ev '(acct-group|acct-user|virtual)/' > pkgs.txt
/usr/local/bin/old_ver 'pkgs.txt' 'old_ver.json'
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

