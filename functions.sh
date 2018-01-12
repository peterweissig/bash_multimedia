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
# 2018 01 11

function multimedia_video_cut_simple() {

    if [ $# -ne 3 ]; then
        echo "Error - multimedia_video_cut_simple needs 3 parameters"
        echo "        #1: start-position (e.g. 0:00:00 == start of video)"
        echo "        #2: end-position   (e.g. 0:01:23 == 1min 23s)"
        echo "        #3: video name     (e.g. stereodata.ogv)"
        echo "The output file will be named \"inputfile_cut_start-end.ext\"."
        echo "    (e.g. stereodata_cut_0_00_00-0_01_23.ogv)"

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
