#!/bin/bash
echo "Download blobs"
if [ $1 ]
then
  VERSION=$1
else
  VERSION=0.0.4
fi
if [ ! -d .downloads ]; then
  mkdir -p .downloads
fi
curl -L https://github.com/shreddedbacon/credhub-webui/releases/download/v$VERSION/credhub-webui-linux-$VERSION.tar.gz > .downloads/credhub-webui-linux-$VERSION.tgz
bosh add-blob .downloads/credhub-webui-linux-$VERSION.tgz credhub-webui/credhub-webui-linux-$VERSION.tgz
