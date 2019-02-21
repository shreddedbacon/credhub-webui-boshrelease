#!/bin/bash
set -eu -o pipefail
pushd bosh-release
rm config/blobs.yml
NEW_VERSION=credhub-webui-linux-$(cat ../amsa-drupal-external/version).tgz
bosh add-blob ../credhub-webui-external/NEW_VERSION credhub-webui/NEW_VERSION
repo_changes=0; git status | grep -q "Changes not staged for commit" && repo_changes=1
if [ $repo_changes == 1 ]
then
  git config --global user.name "BaconBot"
  git config --global user.email "bacon@bot.local"
  git commit -am "Bump version(s) for $NEW_VERSION"
fi
popd

cp -a bosh-release pushgit

echo "finished uploading a new source blob"
exit 0
