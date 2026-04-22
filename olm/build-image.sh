#!/usr/bin/env bash

set -x

git config --global --add safe.directory "$(pwd)"

CONTAINER_CLI="${CONTAINER_CLI:-podman}"

version="v1.19.5"
registry="container-registry.oracle.com/olcne"
git_commit="$(git rev-parse --short HEAD)"

for component in acmesolver cainjector controller startupapicheck webhook; do
	name="cert-manager-${component}"
	docker_tag="${registry}/${name}:${version}"
	"${CONTAINER_CLI}" build --pull \
		--network host \
		--build-arg https_proxy="${https_proxy}" \
		--volume /etc/yum.repos.internal.d:/etc/yum.repos.internal.d \
		--volume /etc/yum.conf:/etc/yum.conf \
		--build-arg VERSION="${version}" \
		--build-arg GIT_COMMIT="${git_commit}" \
		-t ${docker_tag} -f ./olm/builds/Dockerfile."${component}" .
done
