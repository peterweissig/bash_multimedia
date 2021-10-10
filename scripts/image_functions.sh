#!/bin/bash

#***************************[image]*******************************************

# 2020 02 02
function multimedia_image_shrink_all() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <size> [<prefix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: longest side of reduced image (e.g. 1920)"
        echo "    [#2:]additional prefix for reduced files (e.g. shrink_)"
        echo "         if not set, the given size will be used"
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

    overwrite_flag=""
    if [ $# -lt 2 ]; then
        prefix="$1px_"
    else
        prefix="$2"

        if [ "$2" == "" ]; then
            echo "All image files will be overwritten."
            echo -n "Do you wish to continue ? (No/yes)"
            read answer
            if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
              [ "$answer" != "yes" ]; then

                echo "$FUNCNAME: Aborted."
                return
            fi
        fi
        overwrite_flag="-y"
    fi

    if [ $# -lt 3 ]; then
        filter="*.jpg"
    else
        filter="$3"
    fi

    ### using find and ffmpeg
    # simpler, but slower
    find -maxdepth 1 -iname "$filter" -exec bash -c "
      infile=\"\$(basename \"{}\")\"; echo \"  infile: \$infile\";
      outfile=\"${prefix}\${infile}\"; echo \"  outfile: \$outfile\";
      ffmpeg -loglevel quiet ${overwrite_flag} -i \"\${infile}\" \
      -vf scale=w=$1:h=$1:force_original_aspect_ratio=decrease \
      \"\${outfile}\"" \;

    ### using imagemagick
    # more efficient, but needs more cpu and ram
    #if [ "$prefix" == "" ]; then
    #    # note: for mogrify the filenames must be placed after the resizing
    #    mogrify -resize $1x$1\> $filter
    #else
    #    convert $filter -resize $1x$1\> -set filename:new "${prefix}%f" "%[filename:new]"
    #fi
}



# 2021 10 10
function multimedia_image_cut() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <size> [<prefix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: final size after cutting"
        echo "         <width>x<height>[+<left>[+<top>]])"
        echo "         e.g. 400x600   or   320x240+160   or  1000x500+100+100"
        echo "    [#2:]additional prefix for cut images"
        echo "         if not set,  'cut_' will be used"
        echo "    [#3:]search-expression (default \"*.jpg\")"
        echo "The images will be cut and renamed, if possible."
        echo "  (e.g. from image.jpg with 640x480"
        echo "   to cut_image.jpg with 320x240)"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    size="$1"

    if [ $# -lt 2 ]; then
        prefix="cut_"
    else
        prefix="$2"

        if [ "$2" == "" ]; then
            echo "All image files will be overwritten."
            echo -n "Do you wish to continue ? (No/yes)"
            read answer
            if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
              [ "$answer" != "yes" ]; then

                echo "$FUNCNAME: Aborted."
                return
            fi
        fi
    fi

    if [ $# -lt 3 ]; then
        filter="*.jpg"
    else
        filter="$3"
    fi

    ### using find and convert
    find -maxdepth 1 -iname "$filter" -exec bash -c "
      infile=\"\$(basename \"{}\")\"; echo \"  infile: \$infile\";
      outfile=\"${prefix}\${infile}\"; echo \"  outfile: \$outfile\";
      convert \"\${infile}\" -crop "$size" \"\${outfile}\"" \;
}

