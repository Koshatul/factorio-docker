#!/bin/ash

if [[ ! -f "${SAVE}" ]]; then
	${HOME}/bin/x64/factorio --create "${SAVE}"
fi

if [[ ! -f "/config/server-settings.json" ]]; then
	cp "/factorio/data/server-settings.example.json" "/config/server-settings.json"
fi



if [[ ! -z ${1} ]]; then
	${HOME}/bin/x64/factorio "${@}"
else
	${HOME}/bin/x64/factorio --server-settings "/config/server-settings.json" --start-server "${SAVE}"
fi
