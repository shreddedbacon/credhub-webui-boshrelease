#!/bin/bash
echo "Download blobs"
VERSION=0.0.1
if [ ! -d src/credhub-webui ]; then
  mkdir -p src/credhub-webui
fi
curl -L "https://github.com/shreddedbacon/credhub-webui/releases/download/v$VERSION/credhub-webui-linux-$VERSION.tgz > src/credhub-webui/credhub-webui-linux-$VERSION.tgz"
