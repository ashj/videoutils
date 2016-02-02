#!/bin/bash


## DEBUG echo.
function echoDbg {
    [[ "$DBG" == "1" ]] && echo "$(basename $(readlink -f $0)) DEBUG:: $1";
}



function yt-dl_init_config {
    if [[ ! -e "${HOME}/.config/youtube-dl/config" ]]; then
        # Directory where this script is stored.
        local SCRIPT_DIR="$(dirname $(readlink -f $0))"

        mkdir -p ${HOME}/.config/youtube-dl
        ln -s "${SCRIPT_DIR}/youtube-dl-config" "${HOME}/.config/youtube-dl/config"

        echoDbg "Created file: ${HOME}/.config/youtube-dl/config"
    else
        echoDbg "File: ${HOME}/.config/youtube-dl/config already exist."
    fi
}


function rapid-blaster-nico {
    local DIR="${HOME}/shared_repos/rapid_blaster"
    local URL="http://www.nicovideo.jp/mylist/52638165"
    local AVOID_LQ="--min-filesize 50.0m"

    do-stuff "${DIR}" "${URL}" "--playlist-start 61 ${AVOID_LQ}"

    #sleep 20; do-stuff "${DIR}" "${URL}" "--playlist-start 30 --playlist-end 60 ${AVOID_LQ}"
    #sleep 20; do-stuff "${DIR}" "${URL}" "--playlist-start 1  --playlist-end 29 ${AVOID_LQ}"
}

###
# URL - url to download
# PARAMS - params to the downloader
###

function do-stuff {
    local DIR="$1"
    local URL="$2"
    local PARAMS="$3"

    [[ ! -d "${DIR}" ]] && mkdir -p "${DIR}"

    pushd "${DIR}" > /dev/null

    if [[ ! -z "${PARAMS}" ]]; then
        youtube-dl ${PARAMS} "${URL}"
    else
        youtube-dl "${URL}"
    fi

    popd > /dev/null

}
yt-dl_init_config
#rapid-blaster-nico

