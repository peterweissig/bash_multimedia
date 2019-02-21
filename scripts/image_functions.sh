#!/bin/bash

#***************************[image]*******************************************
# 2019 02 20

function multimedia_image_shrink_all() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <size> [<prefix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: longest side of reduced image (e.g. 1920)"
        echo "    [#2:]additional prefix for reduced files (e.g. shrink_)"
        echo "         if not set (empty string) the given size will be used"
        echo "         (e.g. '1920px_')"
        echo "    [#3:]search-expression (default \"*.jpg\")"
        echo "The images will be shrinked to the given size and renamed."
        echo "  (e.g. from image.jpg with 3840x2160"
        echo "   to shrink_image.jpg with 1920x1080)"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ "$2" == "" ]; then
        prefix="$1px_"
    else
        prefix="$2"
    fi

    if [ $# -lt 3 ]; then
        filter="*.jpg"
    else
        filter="$3"
    fi

    # iterate over all files
    find -maxdepth 1 -iname "$filter" -exec bash -c "
      infile=\"\$(basename \"{}\")\"; echo \"  infile: \$infile\";
      outfile=\"${prefix}\${infile}\"; echo \"  outfile: \$outfile\";
      ffmpeg -loglevel quiet -i \"\${infile}\" \
      -vf scale=w=$1:h=$1:force_original_aspect_ratio=decrease \
      \"\${outfile}\"" \;
}