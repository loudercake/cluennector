#!/usr/bin/env bash

cd build/
mkdir -p release

wget https://github.com/tcnksm/ghr/releases/download/v0.14.0/ghr_v0.14.0_linux_amd64.tar.gz
tar -xvzf ghr_*.tar.gz
mv ghr_*_amd64 ghr

zip linuz.zip linux/*
zip macos.zip macos/*
zip windows.zip windows/*
mv *.zip release/

VERSION=$(git describe --tags --abbrev=0 || echo "v0")
./ghr/ghr -t ${GITHUB_TOKEN} -u ${CIRCLE_PROJECT_USERNAME} -r ${CIRCLE_PROJECT_REPONAME} -c ${CIRCLE_SHA1} -delete ${VERSION} ./release/