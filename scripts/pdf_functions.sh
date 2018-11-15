#!/bin/bash

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

# 2018 11 15

function multimedia_pdf_images_extract() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameters"
        echo "     #1: document name        (e.g. paper.pdf)"
        echo "All images from the document will be stored in the local"
        echo "  subfolder \"img/\"."
        echo "  Naming will be <page_nr>-<img_nr>.<extension>"
        echo "  (e.g. img/001-012.png)"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ ! -f "$1" ]; then
        echo "$FUNCNAME: file \"$1\" does not exist."
        return -1;
    fi

    if [ ! -d "img/" ]; then
        echo "mkdir img/"
        mkdir -p "img/"
    else
        echo "folder img/ already exists"
    fi

    tmp="$(basename "$1")"
    pdfimages -p -png -j "${1}" "img/${tmp%.*}"
}

