#!/bin/bash

# requires:
# for avconv
# sudo apt-get install libav-tools
# sudo apt-get install imagemagick --fix-missing

# Put anything to debug, leave empty to not debug
#DEBUG="true"



IFS=$'\n'
OUTPUT_DIR=thumbnail_gallery
DEFAULT_QUANTITY=20
TEMP_DIR=temp
POSSIBLE_VIDEO_FORMATS="mp4|webm|mkv"

#Debug function
function echoD {
    [ -z ${DEBUG} ] || echo "$1"
}



[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"

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


# Skip thumbnails generation in case montage alread exist
    if [[ -f "${OUTPUT_DIR}/${FINAL_FILENAME}.png" ]]; then
         echo "SKIP. ${OUTPUT_DIR}/${FINAL_FILENAME}.png already exist."
         continue;
    fi


######## thumbnail from video
    # Extract video duration
    TEMPDURATION=$(avprobe "${FILENAME}" 2>&1 | grep 'Duration' | awk '{print $2}' | sed s/.[0-9]*,//)
    echoD "TEMPDURATION=$TEMPDURATION"

    # Convert hh:mm:ss from above to seconds
    VIDEO_DURATION=$(echo "$TEMPDURATION" | sed 's/:/*60+/g;s/*60/&&/' | bc)
    echoD "VIDEO_DURATION=$VIDEO_DURATION (seconds)"

    # Receive number of thumbnails to use.
    INPUT_QUANTITY=$1
    if [[ -z "${INPUT_QUANTITY}" ]]; then
        INPUT_QUANTITY=${DEFAULT_QUANTITY}
    fi

    # Get two extra images, to be discarted - at start and at ending
    (( INPUT_QUANTITY += 1 ))
    echoD "INPUT_QUANTITY=$INPUT_QUANTITY"

    # Calculate period to snap the images
    PERIOD=$(echo "($VIDEO_DURATION / $INPUT_QUANTITY )" | bc -l)
    echoD "PERIOD = $PERIOD"

    rm -rf "${TEMP_DIR}"
    [[ ! -d "${TEMP_DIR}" ]] && mkdir "${TEMP_DIR}"




## [start] Get thumbnails for montage
    echo "    Getting thumbnails for montage."
    for i in $(seq -w 2 ${INPUT_QUANTITY}); do

        # Extract frames
        avconv -ss $(echo $i*$PERIOD | bc) \
        -i "${FILENAME}" \
        -vframes 1 \
            -f image2 \
            -vf scale=-1:144 \
            "${TEMP_DIR}/capture-$i.bmp" > /dev/null 2>&1
    done


    # Group the images
    echo "    Generating the video thumbnails montage."
    montage -title "${FINAL_FILENAME}" \
        -font /usr/share/fonts/truetype/fonts-japanese-gothic.ttf \
        -geometry +4+4 \
        "temp/capture*.bmp" "${OUTPUT_DIR}/${FINAL_FILENAME}.png"

## [end] Get thumbnails for montage



## [start] Animated video preview
    NUMSCENES=2
    FPS=20
    TOTAL_DURATION=12

    SCENEDURATION=$(echo "$TOTAL_DURATION / $NUMSCENES" | bc -l)

    echo "    Generating animated thumbnail scenes."
    for i in $(seq 1 ${NUMSCENES} ); do
        SEEKTIME=$(echo "${VIDEO_DURATION} * $i / ($NUMSCENES+1)" | bc)
        echoD "Got gif anim. SEEKTIME=$SEEKTIME"

        # Extract frames
        echo "        Extracting scene $i of $NUMSCENES."
        avconv -ss ${SEEKTIME} \
            -i "${FILENAME}" \
            -t "${SCENEDURATION}" \
            -r "${FPS}" \
            -vf scale=-1:144 \
            -f image2pipe \
            -vcodec ppm - 2>/dev/null | \
                convert -delay "1x${FPS}" - gif:- | \
                    convert -layers Optimize - \
                    "${TEMP_DIR}/${FINAL_FILENAME}-$SEEKTIME.gif" &
    done

    wait
    echo "    Generating video animated preview."
    convert "${TEMP_DIR}/*.gif" "${OUTPUT_DIR}/${FINAL_FILENAME}.gif"

## [end] Animated video preview



    echo "This file is done.
"
    rm -rf "${TEMP_DIR}"
######## END - loop
done



echo "Everything is done. Check ${OUTPUT_DIR} directory."
# END OF FILE
