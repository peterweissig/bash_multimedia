#***************************[files]*******************************************
# 2018 08 22

function multimedia_filename_clean() {

    if [ $# -gt 1 ]; then
        echo "Error - multimedia_filename_clean needs 0-1 parameters"
        echo "       [#1:]search-expression (e.g. \"*.jpg\")"
        echo "            leave option empty to rename regular files"
        echo "            for wildcard-expressions please use double-quotes"
        echo "The files will be renamed from"
        echo "  \"file ä ß Ö.ext\" to \"file_ae_ss_Oe.ext\"."

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
          sed 's/ä/ae/; s/ü/ue/; s/ö/oe/; s/Ä/Ae/; s/Ü/Ue/; s/Ö/Oe/g' | \
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

        echo "multimedia_filename_clean: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "multimedia_filename_clean: Stopping because of an error."
            return -1;
        fi

        # check if filename would change
        if [ "${filelist[$i]}" != "${corrected[$i]}" ]; then
            echo "renaming \"${corrected[$i]}\""
            mv "${filelist[$i]}" "${corrected[$i]}"
        fi
    done
}

function multimedia_filename_add() {

    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Error - multimedia_filename_add needs 1-2 parameters"
        echo "        #1: additional String (e.g. _new)"
        echo "       [#2:]search-expression (e.g. \"*.jpg\")"
        echo "            leave option empty to rename regular files"
        echo "            for wildcard-expressions please use double-quotes"
        echo "The files will be renamed from"
        echo "  \"file.jpg\" to \"file_new.jpg\"."

        return -1
    fi


    # init variables
    changed=0
    updated=()

    # read all filenames
    readarray -t filelist <<< "$(ls $2)"

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
        updated[$i]="${path}${base}${1}${ext}"

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

        echo "multimedia_filename_add: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "multimedia_filename_add: Stopping because of an error."
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
# 2018 01 11

function multimedia_pdf_page_extract() {

    if [ $# -ne 3 ]; then
        echo "Error - multimedia_pdf_page_extract needs 3 parameters"
        echo "        #1: number of first page (e.g. 1 == first page)"
        echo "        #2: number of last page  (e.g. 04)"
        echo "        #3: document name        (e.g. paper.pdf)"
        echo "The output file will be named \"inputfile_pXX-pYY.pdf\"."
        echo "    (e.g. paper_p1-p04.pdf)"

        return -1
    fi

    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage=${1} \
       -dLastPage=${2} \
       -sOutputFile=${3%.pdf}_p${1}-p${2}.pdf \
       ${3}
}


#***************************[video]*******************************************
# 2018 01 14

function multimedia_video_cut_simple() {

    if [ $# -ne 3 ]; then
        echo "Error - multimedia_video_cut_simple needs 3 parameters"
        echo "        #1: start-position (e.g. 0:00:00 == start of video)"
        echo "        #2: duration       (e.g. 0:01:23 == 1min 23s)"
        echo "        #3: video name     (e.g. stereodata.ogv)"
        echo "The output file will be named \"inputfile_cut_start-end.ext\"."
        echo "    (e.g. stereodata_cut_0_00_00-d0_01_23.ogv)"

        return -1
    fi

    filename_path="$(dirname "$3")"
    filename_basename="$(basename "$3")"
    filename_name="${filename_basename%%.*}"
    filename_cut="__cut_${1//:/_}-${2//:/_}"
    filename_ext="${filename_basename#*.}"
    filename="${filename_path}/${filename_name}${filename_cut}.${filename_ext}"

    echo "avconv -i $3 -c:a copy -c:v copy -ss $1 -t $2 $filename"
    avconv -i "$3" -c:a copy -c:v copy -ss "$1" -t "$2" "$filename"
}

function multimedia_video_info() {

    if [ $# -ne 1 ]; then
        echo "Error - multimedia_video_info needs 1 parameter"
        echo "        #1: video name     (e.g. stereodata.ogv)"

        return -1
    fi

    echo "ffprobe $1"
    ffprobe "$1"
}
