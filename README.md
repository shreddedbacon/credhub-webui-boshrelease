# CredHub WebUI BOSH Release
A bosh release to deploy a [credhub web user interface](https://github.com/shreddedbacon/credhub-webui)

# Usage
```
git clone https://github.com/shreddedbacon/credhub-webui-boshrelease.git credhub-webui && cd $_
```
## Deploy
```
bosh -d credhub-webui deploy manifests/deployment.yml
```
## List Instances
```
bosh -d credhub-webui vms
```
## Tail logs
```
bosh -d credhub-webui logs -f
```

# Developing
## Get Blobs
The blobs are downloaded directly from the credhub-webui github releases and stored in src/credhub-webui
```
./get_blobs.sh
```

## Create Release
Create a versioned release tarball, upload to github release with url and sha1sum
```
VERSION=0.0.1
bosh create-release --version=${VERSION} --tarball=credhub-webui-boshrelease-${VERSION}.tgz
SHA1=$(sha1sum credhub-webui-boshrelease-${VERSION}.tgz | awk '{ print $1 }')
cat << EOF
\`\`\`
- name: credhub-webui
  version: ${VERSION}
  sha1: ${SHA1}
  url: https://github.com/shreddedbacon/credhub-webui-boshrelease/releases/download/v${VERSION}/credhub-webui-boshrelease-${VERSION}.tgz
EOF
\`\`\`
```
