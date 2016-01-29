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



function temp-rapid {
    # move lowquality videos away
    mkdir lowquality
    echo "スプラトゥーンＳ＋ガチマッチ01【ラピッドブラスター】-sm27085285.mp4
スプラトゥーンＳ＋ガチマッチ24【ラピッドブラスター】-sm27285174.mp4
スプラトゥーンＳ＋ガチマッチ43【ラピッドブラスター】-sm27679526.mp4
スプラトゥーンＳ＋ガチマッチ44【ラピッドブラスター】-sm27724612.mp4
スプラトゥーンＳ＋ガチマッチ45【ラピッドブラスター】-sm27767281.mp4
スプラトゥーンＳ＋タッグマッチ02【ラピッドブラスター】-sm27701123.mp4
スプラトゥーンＳ＋タッグマッチ03【ラピッドブラスター】-sm27722224.mp4" | while read line; do
        mv "$line" lowquality/
    done

    # redownload lowquality videos. new files must be 100MB.
    local NICOPREF="http://www.nicovideo.jp"
    echo "sm27085285
sm27701123
sm27722224
sm27285174
sm27679526
sm27724612
sm27767281" | while read line; do
         youtube-dl "$NICOPREF/$line"
done

    # duplicated (same sm and lowquality) removal
    mkdir duplicated
    echo "スプラトゥーンＳ＋タッグマッチ01【デュアルスイーパー】-sm27609668.mp4
スプラトゥーンＳ＋ガチマッチ07【スプラシューターコラボ】-sm27120401.mp4
スプラトゥーンＳ＋ガチマッチ08【ラピッドブラスター】-sm27126582.mp4
スプラトゥーンＳ＋ガチマッチ09【ラピッドブラスター】-sm27134838.mp4
スプラトゥーンＳ＋ガチマッチ10【ラピッドブラスター】-sm27139684.mp4
スプラトゥーンＳ＋ガチマッチ11【ラピッドブラスター】-sm27152445.mp4
スプラトゥーンＳ＋ガチマッチ12【ラピッドブラスター】-sm27159151.mp4
スプラトゥーンＳ＋ガチマッチ13【スプラシューターコラボ】-sm27159191.mp4
スプラトゥーンＳ＋ガチマッチ14【ラピッドブラスター】-sm27165889.mp4
スプラトゥーンＳ＋ガチマッチ15【ラピッドブラスター】-sm27179065.mp4
スプラトゥーンＳ＋ガチマッチ16【ラピッドブラスター】-sm27185973.mp4
スプラトゥーンＳ＋ガチマッチ17【ラピッドブラスター】-sm27193307.mp4
スプラトゥーンＳ＋ガチマッチ18【ラピッドブラスター】-sm27207704.mp4
スプラトゥーンＳ＋ガチマッチ19【ラピッドブラスター】-sm27229329.mp4
スプラトゥーンＳ＋ガチマッチ20【ラピッドブラスター】-sm27236357.mp4
スプラトゥーンＳ＋ガチマッチ21【ラピッドブラスター】-sm27246267.mp4
スプラトゥーンＳ＋ガチマッチ22【ラピッドブラスター】-sm27254748.mp4
スプラトゥーンＳ＋ガチマッチ23【ラピッドブラスター】-sm27273731.mp4
スプラトゥーンＳ＋ガチマッチ25【スプラシューターコラボ】-sm27295068.mp4
スプラトゥーンＳ＋ガチマッチ26【ラピッドブラスター】-sm27307756.mp4
スプラトゥーンＳ＋ガチマッチ27【ラピッドブラスター】-sm27324694.mp4" | while read line; do
        mv "$line" duplicated/
    done
    echo "Maintenace for rapidvideos. Check lowquality and duplicated video dirs."
}


function rapid-blaster-nico {
    local DIR="${HOME}/shared_repos/rapid_blaster"
    local URL="http://www.nicovideo.jp/mylist/52638165"

    #do-stuff "${DIR}" "${URL}" "--playlist-start 1  --playlist-end 29"

    #do-stuff "${DIR}" "${URL}" "--playlist-start 30 --playlist-end last"

    #do-stuff "${DIR}" "${URL}"

    # maintenance function
    temp-rapid
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
        echo youtube-dl "${PARAMS}" "${URL}"
    else
        echo youtube-dl "${URL}"
    fi

    popd > /dev/null

}
yt-dl_init_config
#rapid-blaster-nico

