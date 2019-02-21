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

pushd bosh-release

NEW_VERSION=credhub-webui-linux-$(cat ../credhub-webui-external/version).tar.gz
ls ../credhub-webui-external/
bosh add-blob ../credhub-webui-external/$NEW_VERSION credhub-webui/$NEW_VERSION

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

git config --global user.name "CICD Robot"
git config --global user.email "cicd@oakton.digital"

pushd bosh-release
 git merge --no-edit ${BRANCH}
 git add -A
 git status
 git commit -m "release v${VERSION}"
popd

# so that future steps in the pipeline can push our changes
cp -a bosh-release pushme
