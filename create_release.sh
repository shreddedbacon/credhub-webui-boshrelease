#!/bin/bash
if [ $1 ]
then
  VERSION=$1
else
  VERSION=0.0.3
fi
bosh create-release --force --version=$VERSION --tarball=credhub-webui-boshrelease-${VERSION}.tgz
