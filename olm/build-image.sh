#!/usr/bin/env bash

set -x

git config --global --add safe.directory "$(pwd)"

CONTAINER_CLI="${CONTAINER_CLI:-podman}"

version="1.17.4"
registry="container-registry.oracle.com/olcne"
git_commit="$(git rev-parse --short HEAD)"

repo_filename="ol_artifacts.repo"
repo_file="/etc/yum.repos.d/$repo_filename"
if [ -f "$repo_file" ]; then
	cp "$repo_file" ./
	echo 'priority=1' >> "$repo_filename"
	echo 'enabled=1' >> "$repo_filename"
fi

for component in acmesolver cainjector controller startupapicheck webhook; do
	name="cert-manager-${component}"
	docker_tag="${registry}/${name}:${version}"
	"${CONTAINER_CLI}" build --pull \
		--build-arg https_proxy="${https_proxy}" \
		--build-arg VERSION="${version}" \
		--build-arg GIT_COMMIT="${git_commit}" \
		-t ${docker_tag} -f ./olm/builds/Dockerfile."${component}" .
done
