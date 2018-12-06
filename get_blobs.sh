#!/bin/bash
echo "Download blobs"
if [ ! -d src/credhub-webui ]; then
  mkdir -p src/credhub-webui
fi
curl -L https://github.com/shreddedbacon/credhub-webui/releases/download/v0.0.1/credhub-webui-linux-0.0.1.tgz > src/credhub-webui/credhub-webui-linux-0.0.1.tgz
