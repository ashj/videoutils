#!/bin/bash

function yt-dl_init_config {

if [[ ! -e "${HOME}/.config/youtube-dl/config" ]]; then
    mkdir -p ${HOME}/.config/youtube-dl
    echo "--verbose
--ignore-errors
--playlist-reverse
--sleep-interval 3
--netrc" > ${HOME}/.config/youtube-dl/config
   echo "Created file: ${HOME}/.config/youtube-dl/config"
else
   echo "File: ${HOME}/.config/youtube-dl/config already exist."
fi

if [[ ! -e "${HOME}/.netrc" ]]; then
   touch $HOME/.netrc
   chmod a-rwx,u+rw $HOME/.netrc

   #echo "machine nicovideo login myaccount@gmail.com password insert_password_here" >> $HOME/.netrc

   echo "Created file: ${HOME}/.netrc"
else
   echo "File: ${HOME}/.netrc already exist"
fi


}


function rapid-blaster-nico {
    pushd ~/shared_repos/rapid_blaster > /dev/null

    local URL="http://www.nicovideo.jp/mylist/52638165"

#    URL="${URL}" PARAMS="--playlist-start 1 --playlist-end 29" do-stuff
#    sleep 3
#    URL="${URL}" PARAMS="--playlist-start 30 --playlist-end last" do-stuff

URL="${URL}" do-stuff

	
	popd > /dev/null
}

###
# URL - url to download
# PARAMS - params to the downloader
###
###
# DEBUG=true - keep log files and detect duplicated files
# DEBUG2=true - will create dummy files instead of doing the real thing
###

function do-stuff {
    local mPREV=prev.txt
    local mCURR=curr.txt
    local mMD5SUM=md5.txt
    local mREPEATED=duplicates.txt

    local mLOGFILES="${mPREV}|${mCURR}|${mMD5SUM}|${mREPEATED}"


    # previous file list
    ls -1 | sort | grep -vE "${mLOGFILES}" > prev.txt


    # do the stuff
    if [[ "${DEBUG2}" == "true" ]]; then
        local STRING=$(date +%Y%m%d_%H:%M:%S)
        echo "${STRING}" > "${STRING}.test.txt"
    else
        echo "Starting..."
        youtube-dl "${PARAMS}" "${URL}"
    fi

    # current file list
    ls -1 | sort | grep -vE "${mLOGFILES}" > curr.txt

    # check for duplicates
    if [[ "${DEBUG}" == "true" ]]; then
        # get the files md5sum
        rm -f "${mMD5SUM}"
        ls -1 | sort | grep -vE "${mLOGFILES}" | while read line; do
            md5sum "${line}" >> "${mMD5SUM}";
        done

       # list repeated files
       rm -f "{$mREPEATED}"
       cat "${mMD5SUM}" | cut -d ' ' -f 1 | sort | uniq -d | while read line; do
           grep "${line}" "${mMD5SUM}" >> "${mREPEATED}";
       done
    fi

    # check differences between the file lists...
    local mDIFF=$(diff prev.txt curr.txt | grep -E "^>|^<" | sed "s/^>/+/g" | sed "s/^</-/g")

    # then present the differences, if they exist
    if [[ -z "${mDIFF}" ]]; then
        echo "No new files detected."
        echo ""
    else
        echo "Differences in files found:"
        echo "${mDIFF}"
        echo ""
    fi

    # finally, clear the lists
    if [[ "${DEBUG}" == "true" ]]; then
        echo "All done. Check log files."
    else
        rm -f "${mPREV}" "${mCURR}" "${mMD5SUM}" "${mREPEATED}"
    fi
}
yt-dl_init_config
rapid-blaster-nico

