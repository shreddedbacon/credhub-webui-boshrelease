#!/bin/bash
set -eu -o pipefail

header() {
	echo
	echo "###############################################"
	echo
	echo $*
	echo
}

echo "0+dev.1" > /tmp/version
if [[ -z ${VERSION_FROM} ]]; then
  VERSION_FROM=/tmp/version
fi
VERSION=$(cat ${VERSION_FROM})

git config --global user.name "BaconBot"
git config --global user.email "bacon@bot"

cat > bosh-release/config/private.yml << EOF
---
blobstore:
  options:
    access_key_id: ${AWS_ACCESS_KEY}
    secret_access_key: ${AWS_SECRET_KEY}
    endpoint: ${AWS_ENDPOINT}
EOF

pushd bosh-release

NEW_VERSION=credhub-webui-linux-$(cat ../credhub-webui-external/version).tar.gz
bosh add-blob ../credhub-webui-external/$NEW_VERSION credhub-webui/$NEW_VERSION
repo_changes=0; git status | grep -q "Changes not staged for commit" && repo_changes=1
if [ $repo_changes == 1 ]
then
  git status
  git commit -m "new blob $NEW_VERSION" config/blobs.yml
fi

mkdir -p releases/${RELEASE_NAME}/${RELEASE_NAME}
bosh -n create-release --tarball=releases/${RELEASE_NAME}/${RELEASE_NAME}-${VERSION}.tgz --version "${VERSION}" --final
popd

mkdir -p gh/artifacts
echo "v${VERSION}"                         > gh/tag
echo "${RELEASE_NAME} v${VERSION}"         > gh/name
#mv bosh-release/ci/release_notes.md          gh/notes.md
echo "Release ${RELEASE_NAME} v${VERSION}" > gh/notes.md
cp bosh-release/releases/${RELEASE_NAME}/${RELEASE_NAME}-${VERSION}.tgz  gh/artifacts
SHA1=$(sha1sum bosh-release/releases/${RELEASE_NAME}/${RELEASE_NAME}-${VERSION}.tgz | head -n1 | awk '{print $1}')

cat >> gh/notes.md <<EOF
### CredHub WebUI BOSH Release
### Deployment Information
\`\`\`yaml
releases:
- name: credhub-webui
  version: $VERSION
  sha1: $SHA1
  url: https://github.com/shreddedbacon/credhub-webui-boshrelease/releases/download/v$VERSION/credhub-webui-boshrelease-$VERSION.tgz
\`\`\`
EOF

pushd bosh-release

head -n -5 manifests/deployment.yml > manifests/deployment.yml.tmp
echo "releases:
- name: credhub-webui
  version: $VERSION
  sha1: $SHA1
  url: https://github.com/shreddedbacon/credhub-webui-boshrelease/releases/download/v$VERSION/credhub-webui-boshrelease-$VERSION.tgz" >> manifests/deployment.yml.tmp
mv manifests/deployment.yml.tmp manifests/deployment.yml

git merge --no-edit ${BRANCH}
git add -A
git status
git commit -m "release v${VERSION}"
popd

# so that future steps in the pipeline can push our changes
cp -a bosh-release pushme
