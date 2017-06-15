#!/bin/bash

if [[ ! -z ${1} ]]; then
	${HOME}/bin/x64/factorio "${@}"
else
	${HOME}/bin/x64/factorio --server-settings "/config/server-settings.json" --generate-map-preview "${SAVE}.png" --start-server "${SAVE}"
fi
