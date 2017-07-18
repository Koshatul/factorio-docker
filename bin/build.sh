#!/bin/bash
##############################################################################################
## Build script for Factorio docker server, runs in cronjob and updates
## docker hub with new versions as they are released
##############################################################################################

DOCKER_IMAGE="koshatul/factorio"

BASE_DIR="$(cd $(dirname ${0})/..; pwd)"
echo "INFO Base Directory: ${BASE_DIR}"
BUILD_DONE="0"
BIN_REVERSE_ORDER="tail -r"
if [[ "$(which tac)" != "" ]]; then
	BIN_REVERSE_ORDER="$(which tac)"
fi

function docker_tag_exists() {
	curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

function docker_build_factorio() {
	VERSION="${1}"
	RELEASE_URL="${2}"
	if docker_tag_exists "${DOCKER_IMAGE}" "${VERSION}"; then
		echo "INFO Skipping, already on Docker Hub"
		return;
	fi
	BUILD_DONE="1"
	BUILD_DIR="$(mktemp -d)"
	echo "INFO Build Directory: ${BUILD_DIR}"
	cp ${BASE_DIR}/Dockerfile ${BUILD_DIR}/Dockerfile
	cp ${BASE_DIR}/init.sh ${BUILD_DIR}/init.sh
	sed -i.orig -e "s#^ENV VERSION .*#ENV VERSION ${VERSION}#" -e "s#https://www.factorio.com/download-headless/experimental#${RELEASE_URL}#" ${BUILD_DIR}/Dockerfile
	if [[ -f "${BUILD_DIR}/Dockerfile.orig" && -f "${BUILD_DIR}/Dockerfile" ]]; then
		## Both Files Exist, so check for differences
		diff "${BUILD_DIR}/Dockerfile.orig" "${BUILD_DIR}/Dockerfile"
		RV="${?}"
		if [[ ${RV} == "0" ]]; then
			## Unchanged, so there's a problem
			echo "ERRO Dockerfile version replacement failed, exiting ..." >&2
			exit 99
		fi
	else
		## Missing file from sed change
		echo "ERRO Dockerfile or Dockerfile.orig missing, sed failed" >&2
		exit 99
	fi
	cd "${BUILD_DIR}"
	echo "INFO Building ${DOCKER_IMAGE}:${VERSION}"
	docker build -t "${DOCKER_IMAGE}:${VERSION}" "${BUILD_DIR}"
	echo "INFO Pushing ${DOCKER_IMAGE}:${VERSION}"
	docker push "${DOCKER_IMAGE}:${VERSION}"
	rm -rf "${BUILD_DIR}"
}

## Experimental Builds
EXPERIMENTAL_VERSIONS=($(curl -s https://www.factorio.com/download-headless/experimental | grep -o "/get-download/.*/headless/linux64" | ${BIN_REVERSE_ORDER}))
for EXPERIMENTAL_VERSION in ${EXPERIMENTAL_VERSIONS[*]}; do
	echo "INFO Experimental Version: ${EXPERIMENTAL_VERSION}"
	VERSION="$(echo "${EXPERIMENTAL_VERSION}" | sed -e 's_.*get-download/__;s_/headless.*__')"
	echo "INFO Version: ${VERSION}"
	docker_build_factorio "${VERSION}" "https://www.factorio.com/download-headless/experimental"
done
echo "INFO Experimental Tag: ${VERSION}"
if [[ ${BUILD_DONE} == "0" ]]; then
	echo "INFO No builds run, skipping experimental tag"
else
	docker tag "${DOCKER_IMAGE}:${VERSION}" "${DOCKER_IMAGE}:experimental"
	docker push "${DOCKER_IMAGE}:experimental"
fi


BUILD_DONE="0"
STABLE_VERSIONS=($(curl -s https://www.factorio.com/download-headless/stable | grep -o "/get-download/.*/headless/linux64" | ${BIN_REVERSE_ORDER}))
for STABLE_VERSION in ${STABLE_VERSIONS[*]}; do
	echo "INFO Stable Version: ${STABLE_VERSION}"
	VERSION="$(echo "${STABLE_VERSION}" | sed -e 's_.*get-download/__;s_/headless.*__')"
	echo "INFO Version: ${VERSION}"
	docker_build_factorio "${VERSION}" "https://www.factorio.com/download-headless/stable"
done
echo "INFO Stable Tag: ${VERSION}"
if [[ ${BUILD_DONE} == "0" ]]; then
	echo "INFO No builds run, skipping stable tag"
else
	docker tag "${DOCKER_IMAGE}:${VERSION}" "${DOCKER_IMAGE}:stable"
	docker push "${DOCKER_IMAGE}:stable"
fi
