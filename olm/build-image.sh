#!/usr/bin/env bash

set -x

git config --global --add safe.directory "$(pwd)"

CONTAINER_CLI="${CONTAINER_CLI:-podman}"

version="1.19.1"
registry="container-registry.oracle.com/olcne"
git_commit="$(git rev-parse --short HEAD)"

# Temp change
rm /etc/yum.repos.d/ol_artifacts.repo

for component in acmesolver cainjector controller startupapicheck webhook; do
	name="cert-manager-${component}"
	docker_tag="${registry}/${name}:${version}"
	"${CONTAINER_CLI}" build --pull \
		--build-arg https_proxy="${https_proxy}" \
		--volume /etc/yum.repos.d:/etc/yum.repos.d \
		--build-arg VERSION="${version}" \
		--build-arg GIT_COMMIT="${git_commit}" \
		-t ${docker_tag} -f ./olm/builds/Dockerfile."${component}" .
done
