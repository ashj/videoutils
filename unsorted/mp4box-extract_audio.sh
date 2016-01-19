#!/bin/bash

# requires:
# sudo apt-get install eyeD3 gpac
# for avconv
# sudo apt-get install libav-tools eyeD3

# Put anything to debug, leave empty to not debug
#DEBUG="true"



################################
# CONFIGURE HERE
################################
TAG_ALBUM="NicoDouga"
TAG_ARTIST="NicoDouga"
TAG_GENRE="Podcast"
TAG_YEAR="$(date +%Y)"
DEFAULT_ARTWORK_IMAGE="artwork.png"
DEFAULT_VOLUME_GAIN="1.0"
###############################



IFS=$'\n'
OUTPUT_DIR=audio_only
TEMP_IMAGE=temp.png
POSSIBLE_VIDEO_FORMATS="mp4|webm|mkv"

#Debug function
function echoD {
    [ -z ${DEBUG} ] || echo "$1"
}




function tag-file {
    local AUDIOFILENAME="${1}"
    eyeD3 --remove-v1 --to-v2.4 --set-encoding=utf8 \
 --artist "${TAG_ARTIST}" \
 --album "${TAG_ALBUM}" \
 --title "${FINAL_FILENAME}" \
 --year "${TAG_YEAR}" \
 --genre "${TAG_GENRE}" \
 --no-tagging-time-frame \
 "${AUDIOFILENAME}" > /dev/null 2>&1

    if [ -f "${ARTWORK_IMAGE}" ]; then
        eyeD3 --remove-v1 --to-v2.4 --set-encoding=utf8 \
 --add-image "${ARTWORK_IMAGE}":FRONT_COVER:"FRONT_COVER" \
 "${AUDIOFILENAME}" > /dev/null 2>&1
        echoD "    Added artwork to music file."
    fi
}



[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"



# Change volume of the mp3 file.
if [[ ! -z "$1" ]]; then
    DEFAULT_VOLUME_GAIN="$1"
    echo "Apply custom volume gain (multiplier): ${DEFAULT_VOLUME_GAIN}"
else
    echo "Apply default volume gain (multiplier): ${DEFAULT_VOLUME_GAIN}"
fi
echo ""



# Remove ls aliases to obtain correct list
alias ls='$(which ls)'

# main loop
for FILENAME in $(ls -1 *.* | grep -E "${POSSIBLE_VIDEO_FORMATS}"); do
    echo "Working on ${FILENAME}"


# [start] Get file name without extension and -sm sufix
    EXTENSION=".${FILENAME##*.}"
    TEMP_NAME=$(basename "${FILENAME}" "${EXTENSION}")

    # Demiliter is set by "-sm" at the end of filename
    FINAL_FILENAME=$(echo "${TEMP_NAME}" | sed "s/-sm[0-9]*//" )
    # Restore the title if is empty
    if [[ -z "${FINAL_FILENAME}" ]]; then
        FINAL_FILENAME=${TEMP_NAME};
    fi
    echoD "FINAL_FILENAME: ${FINAL_FILENAME}"
# [end]  Get file name without extension and -sm sufix



# [start] Get front cover artwork from file or video
    echo "    Getting artwork for front cover."
     if [[ -f "${DEFAULT_ARTWORK_IMAGE}" ]]; then
          ARTWORK_IMAGE="${DEFAULT_ARTWORK_IMAGE}"
          echo "        Found file: ${DEFAULT_ARTWORK_IMAGE}. It will be used."
     else
          ARTWORK_IMAGE="${TEMP_IMAGE}"
          avconv -ss 10 -i "${FILENAME}" -vf scale=720:-1 -vframes 1 -f image2 "${ARTWORK_IMAGE}" > /dev/null 2>&1
          echo "        Got the artwork from the video."
     fi
# [end] Get front cover artwork from file or video




# [start] Extract video audio by converting to mp3
    FINALTRACKNAME="${FINAL_FILENAME}.mp3"
    echo "    Converting to mp3 file."
    avconv -i "${FILENAME}" \
        -threads auto \
        -f mp3 \
        -vn \
        -af "volume=volume=${DEFAULT_VOLUME_GAIN}" \
        "${FINALTRACKNAME}" > /dev/null 2>&1
# [end] Extract video audio by converting to mp3



# [start] Tag mp3 file
    echo "    Tagging meta data."
    tag-file "${FINALTRACKNAME}"
# [end] Tag mp3 file



    # Move file to output directory
    mv "${FINALTRACKNAME}" "${OUTPUT_DIR}/${FINALTRACKNAME}"




    # Remove temp files
    if [[ "${DEFAULT_ARTWORK_IMAGE}" != "${ARTWORK_IMAGE}" ]]; then
        rm -f "${ARTWORK_IMAGE}"
    fi




    echo "This file is done.
"
######## END - loop
done

echo "Everything is done. Check ${OUTPUT_DIR} directory."
# END OF FILE
