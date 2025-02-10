#!/bin/bash

#***************************[extraction from pdf]*****************************
# 2024 01 18
function pdf_page_extract()   { multimedia_pdf_page_extract   "$@"; }
function pdf_images_extract() { multimedia_pdf_images_extract "$@"; }
function pdf_shrink()         { multimedia_pdf_shrink         "$@"; }


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


# 2023 04 26
function multimedia_pdf_shrink() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [--tiny | --printer] <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameters"
        echo "     #1: document name        (e.g. paper.pdf)"
        echo "The pdf will be compressed and stored as selected:"
        echo "  --tiny    --> 'screen'  quality, stored as xyz_tiny.pdf."
        echo "  <default> --> 'ebook'   quality, stored as xyz_compressed.pdf."
        echo "  --printer --> 'printer' quality, stored as xyz_printer.pdf."

        return
    fi

    # init variables
    option_compression="compressed"
    param_file=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 2 ]; then
        params_ok=1
        param_file="${@: -1}"
        if [ $# -ge 2 ]; then
            if [ "$1" == "--tiny" ]; then
                option_compression="tiny"
            elif [ "$1" == "--printer" ]; then
                option_compression="printer"
            else
                params_ok=0
            fi
        fi
    fi
    if [ $params_ok -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ ! -f "$param_file" ]; then
        echo "$FUNCNAME: file \"$param_file\" does not exist."
        return -1;
    fi

    # switch between ebook and screen options
    output_file="${param_file%.*}_${option_compression}.pdf"
    if [ "$option_compression" == "tiny" ]; then
        pdfsettings="screen"
    elif [ "$option_compression" == "printer" ]; then
        pdfsettings="printer"
    else # default
        pdfsettings="ebook"
    fi

    gs -q -dNOPAUSE -dBATCH -dSAFER \
      -sDEVICE=pdfwrite \
      -sPDFSETTINGS="$pdfsettings" \
      -dEmbedAllFonts=true \
      -dCompressFonts=false \
      -dAutoRotatePages=/None \
      -sOutputFile="$output_file" \
      "$param_file"
}



#***************************[conversion to pdf]*******************************
# 2025 02 10

temp="config/pandoc/user_templates/"
export MULTIMEDIA_PANDOC_TEMPLATE_USER_DIR="${REPO_BASH_MULTIMEDIA}${temp}"
temp="config/pandoc/"
export MULTIMEDIA_PANDOC_TEMPLATE_DEFAULT_DIR="${REPO_BASH_MULTIMEDIA}${temp}"

# 2025 02 10
function _pandoc_default() { _pandoc_template_helper "default" "$@"; }
function pandoc_simple()   { _pandoc_template_helper "simple"  "$@"; }

# 2025 02 10
function multimedia_pdf_from_markdown() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<template>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameter"
        echo "     #1: document name        (e.g. memo.md)"
        echo "    [#2:]user template name   (e.g. roboag for roboag.latex)"
        echo "The output file will have pdf as extension."
        echo "  (e.g. memo.pdf)"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_filename="$1"
    param_template="default"
    if [ $# -ge 2 ]; then
        param_template="$2"
    fi

    # check if file exists
    if [ ! -e "$1" ]; then
        echo "$FUNCNAME: file \"$1\" does not exist."
        return -1
    fi

    # check/use template
    template="$MULTIMEDIA_PANDOC_TEMPLATE_DEFAULT_DIR${param_template}.latex"
    if [ -e "$template" ]; then
        echo "using predefined template \"$param_template\""
    else
        template="${MULTIMEDIA_PANDOC_TEMPLATE_USER_DIR}${param_template}.latex"
    fi
    if [ ! -e "$template" ]; then
        echo "$FUNCNAME: template \"$param_template\" does not exist."
        echo "    ($template)"
        return -1;
    fi

    # call pandoc
    tmp="$(basename "$param_filename")"
    out_file="${tmp%.*}.pdf"
    echo "pandoc --template=\"$template\" -o \"$out_file\" \"$param_filename\""
    pandoc --template="$template" -o "$out_file" "$param_filename"
}

# 2025 02 10
function _multimedia_pdf_from_markdown_create_aliases() {

    # check if template dir exists
    if [ ! -d "${MULTIMEDIA_PANDOC_TEMPLATE_USER_DIR}" ]; then
        return
    fi

    # read all files
    readarray -t filelist <<< "$(ls --quote-name \
    "${MULTIMEDIA_PANDOC_TEMPLATE_USER_DIR}"*.latex 2>> /dev/null)"

    # iterate over files
    for i in ${!filelist[@]}; do
        # remove outer quotes
        current_filename="$(echo "${filelist[$i]:1:-1}")"

        # expand special characters and simplify \" to "
        current_filename="$(printf "${current_filename}")"

        # filename only (no directories)
        current_filename="$(basename "${current_filename}")"

        # remove extension
        current_filename="${current_filename%.*}"

        # check filename
        if [ $? -ne 0 ] || [ "$current_filename" == "" ]; then
            continue;
        fi

        # create function
        eval "function pandoc_$current_filename() {
            _pandoc_template_helper \"$current_filename\" \"\$@\"
        }"
    done
}

# 2025 02 10
function _pandoc_template_helper() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <template> <filename>"
        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2 parameters"
        echo "     #1: template name        (e.g. simple)"
        echo "     #2: document name        (e.g. memo.md)"
        echo "This function is calling multimedia_pdf_from_markdown:"
        echo "    \$ multimedia_pdf_from_markdown \"#2\" \"#1\""
        return
    fi

    param_template="$1"
    param_filename="$2"

    if [ "$param_template" == "" ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    funcname="pandoc_$param_template"

    # print help
    if [ "$param_filename" == "-h" ]; then
        echo "$funcname <filename>"
        return
    fi
    if [ "$param_filename" == "--help" ]; then
        echo "$funcname needs 1 parameter"
        echo "     #1: document name        (e.g. memo.md)"
        echo "This function is calling multimedia_pdf_from_markdown:"
        echo "    \$ multimedia_pdf_from_markdown \"#1\" $param_template"
        return
    fi

    # check parameter
    if [ $# -ne 2 ]; then
        echo "$funcname: Parameter Error."
        $FUNCNAME "$param_template" --help
        return -1
    fi

    if [ ! -e "$param_filename" ]; then
        echo "$funcname: file \"$param_filename\" does not exist."
        return -1
    fi

    echo "multimedia_pdf_from_markdown \"$param_filename\" $param_template"
    multimedia_pdf_from_markdown "$param_filename" "$param_template"
}
