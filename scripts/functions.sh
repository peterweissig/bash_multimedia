#!/bin/bash

#***************************[files]*******************************************
# 2018 09 26

function multimedia_filename_clean() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]search-expression (e.g. \"*.jpg\")"
        echo "         Leave option empty to rename all regular files."
        echo "         For wildcard-expressions please use double-quotes."
        echo "The files will be renamed to remove ä, ü, ö, ß and spaces."
        echo "  (e.g. from \"file ä ß Ö.ext\" to file_ae_ss_Oe.ext)"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    changed=0
    corrected=()

    # read all filenames
    readarray -t filelist <<< "$(ls $1)"

    # iterate over all files
    for i in ${!filelist[@]}; do
        # replace bad letters
        corrected[i]=$(echo "${filelist[$i]}" | \
          sed 's/[ /\:]\+/_/g' | \
          sed 's/ä/ae/g; s/ü/ue/g; s/ö/oe/g; s/Ä/Ae/g; s/Ü/Ue/g; s/Ö/Oe/g' | \
          sed 's/ß/ss/g');

        # check if filename would change
        if [ "${filelist[$i]}" != "${corrected[$i]}" ]; then
            echo "  \"${filelist[$i]}\" ==> \"${corrected[$i]}\""
            changed=1
        fi
    done

    if [ $changed -eq 0 ]; then
        # output if nothing was changed
        echo "All files comply :-)"
        return
    fi

    # ask user if continuing
    echo -n "Do you wish to continue (N/y)?"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
      [ "$answer" != "yes" ]; then

        echo "$FUNCNAME: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi

        # check if filename would change
        if [ "${filelist[$i]}" != "${corrected[$i]}" ]; then
            echo "renaming \"${corrected[$i]}\""
            mv "${filelist[$i]}" "${corrected[$i]}"
        fi
    done
}

function multimedia_filename_expand() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <prefix> [<suffix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: additional prefix (e.g. file_)"
        echo "    [#2:]additional suffix (e.g. _new)"
        echo "    [#3:]search-expression (e.g. \"*.jpg\")"
        echo "         Leave option empty to rename all regular files."
        echo "         For wildcard-expressions please use double-quotes."
        echo "The output files will be named"
        echo "  \"<path><prefix><filename><suffix><extension>\"."
        echo "  (e.g. from image.jpg to file_image_new.jpg)."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    changed=0
    updated=()

    # read all filenames
    readarray -t filelist <<< "$(ls $3)"

    # iterate over all files
    for i in ${!filelist[@]}; do
        # split filename
        path="$(dirname ${filelist[$i]})"
        if [ "$path" == "." ]; then
            path="";
        else
            path="${path}/";
        fi

        baseext="$(basename ${filelist[$i]})"
        base="${baseext%.*}"
        ext="${baseext/*./.}"
        if [ "$ext" == "$baseext" ]; then
            ext="";
        fi

        # create new name
        updated[$i]="${path}${1}${base}${2}${ext}"

        # rename file
        echo "  \"${filelist[$i]}\" ==> \"${updated[$i]}\""
        changed=1
    done

    if [ $changed -eq 0 ]; then
        # output if nothing was changed
        echo "No files found :-("
        return
    fi

    # ask user if continuing
    echo -n "Do you wish to continue (N/y)?"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
      [ "$answer" != "yes" ]; then

        echo "$FUNCNAME: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi

        # check if filename would change
        if [ "${filelist[$i]}" != "${updated[$i]}" ]; then
            echo "renaming \"${updated[$i]}\""
            mv "${filelist[$i]}" "${updated[$i]}"
        fi
    done
}


#***************************[documents]***************************************
# 2018 08 24

function multimedia_pdf_page_extract() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <start> <end> <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 3 parameters"
        echo "     #1: number of first page (e.g. 1 == first page)"
        echo "     #2: number of last page  (e.g. 04)"
        echo "     #3: document name        (e.g. paper.pdf)"
        echo "The output file will be named"
        echo "  \"<filename>_p<start>-p<end>.pdf\"."
        echo "  (e.g. paper_p1-p04.pdf)"

        return
    fi

    # check parameter
    if [ $# -ne 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage=${1} \
       -dLastPage=${2} \
       -sOutputFile=${3%.pdf}_p${1}-p${2}.pdf \
       ${3}
}


#***************************[video]*******************************************
# 2018 09 03

function multimedia_video_info() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: video name     (e.g. stereodata.ogv)"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print infos
    echo "ffprobe $1"
    ffprobe "$1"
}

function multimedia_video_cut_simple() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <start> <duration> <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 3 parameters"
        echo "     #1: start-position (e.g. 0:00:00 == start of video)"
        echo "     #2: duration       (e.g. 0:01:23 == 1min 23s)"
        echo "     #3: video name     (e.g. stereodata.ogv)"
        echo "The output file will be named"
        echo "  \"<filename>__cut_<start>-d<duration>.ext\"."
        echo "  (e.g. stereodata__cut_0_00_00-d0_01_23.ogv)"

        return
    fi

    # check parameter
    if [ $# -ne 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # create filename
    filename_path="$(dirname "$3")"
    filename_basename="$(basename "$3")"
    filename_name="${filename_basename%%.*}"
    filename_cut="__cut_${1//:/_}-d${2//:/_}"
    filename_ext="${filename_basename#*.}"
    filename="${filename_path}/${filename_name}${filename_cut}.${filename_ext}"

    # create video
    echo "avconv -i $3 -c:a copy -c:v copy -ss $1 -t $2 $filename"
    avconv -i "$3" -c:a copy -c:v copy -ss "$1" -t "$2" "$filename"
}
