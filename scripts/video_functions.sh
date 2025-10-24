#!/bin/bash

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

# 2025 10 23
function multimedia_videos_shrink() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <compression> [<prefix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: Compression (Constant Rate Factor 24..30)"
        echo "    [#2:]additional prefix for reduced files (e.g. shrink_)"
        echo "         if not set, the given crf will be used"
        echo "         (e.g. 'crf24_')"
        echo "    [#3:]search-expression (default \"*.jpg\")"
        echo "The videos will be shrunk with the given CRF."
        echo "  (e.g. from video.mp4 to shrink_video.mp4 with CRF=24)"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    crf="$1"

    overwrite=0
    if [ $# -lt 2 ]; then
        prefix="crf${crf}_"
    else
        prefix="$2"

        if [ "$2" == "" ]; then
            echo "All video files will be overwritten."
            echo -n "Do you wish to continue ? (No/yes)"
            read answer
            if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
              [ "$answer" != "yes" ]; then

                echo "$FUNCNAME: Aborted."
                return
            fi
            overwrite=1
            prefix="shrink_"
        fi
    fi

    if [ $# -lt 3 ]; then
        filter="*.mp4"
    else
        filter="$3"
    fi

    ### using find and ffmpeg
    find -maxdepth 1 -iname "$filter" -exec bash -c "
      folder=\"\$(dirname \"{}\")/\";
      infile=\"\$(basename \"{}\")\"; echo \"  infile: \$infile\";
      outfile=\"${prefix}\${infile}\"; echo \"  outfile: \$outfile\";
      ffmpeg -loglevel quiet -i \"\${folder}\${infile}\" \
        -vcodec libx265 -crf ${crf} \"\${folder}\${outfile}\"
      if [ $overwrite -ne 0 ]; then
          echo \"mv: \$outfile --> \$infile\";
          mv \"\${folder}\${outfile}\" \"\${folder}\${infile}\";
      fi;
      " \;
}

# 2022 11 06
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
    echo "ffmpeg -i $3 -c:a copy -c:v copy -ss $1 -t $2 $filename"
    ffmpeg -i "$3" -c:a copy -c:v copy -ss "$1" -t "$2" "$filename"
}
