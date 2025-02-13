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

# 2025 02 12
function _pandoc_default() { _pandoc_template_helper "default" "$@"; }
function pandoc_simple()   { _pandoc_template_helper "simple"  "$@"; }
function pandoc_meeting_public() { _pandoc_template_helper "meeting" "$@" modePublic; }
function pandoc_meeting_intern() { _pandoc_template_helper "meeting" "$@" modeIntern; }
function pandoc_meeting_geheim() { _pandoc_template_helper "meeting" "$@" modeGeheim; }

# 2025 02 12
function _pandoc_meeting_helper(){

    if [ $# -ne 1 ] || [ "$1" == "" ]; then
        return -1
    fi

    command="$1"

    # enable multiline replacement
    echo "-z"
    # replace simple command
    echo "-e s/\\n\\\\${command}{[^}]*}\\n/\\n/g"
    echo "-e s/\\\\${command}{[^}]*}//g"

    # replace helper symbols
    echo "-e s/@/@o/g -e s/{/@s/g -e s/}/@e/g"

    # replace environment start & end with helper symbols
    echo "-e s/\\\\Anfang${command^}/{/g"
    echo "-e s/\\\\Ende${command^}/}/g"

    # replace simple command
    echo "-e s/\\n{[^}]*}\\n/\\n/g"
    echo "-e s/{[^}]*}//g"

    # check for remaining start or end and drop an error
    echo "-e s/[{}]/\\n\\\\Error{}\\n/g"

    # reset helper symbols
    echo "-e s/@e/}/g -e s/@s/{/g -e s/@o/@/g"
}

function pandoc_meeting(){

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs at 1 parameter"
        echo "     #1: document name        (e.g. memo.md)"
        echo -n "This wrapper will first export up to three (simplified)"
          echo " versions of the input markdown:"
        echo "- <orignal_name>__geheim.<ext> (not modified)"
        echo "- <orignal_name>__intern.<ext> (without secret notes)"
        echo "- <orignal_name>__public.<ext> (without internal/secret notes)"
        echo ""
        echo -n "If any two exported markdowns are identical, only the"
          echo " least secret version is kept."
        echo ""
        echo "Afterwards, each existing version is converted to the respective pdf:"
        echo "- <orignal_name>__geheim.<ext> --> <original_name>__geheim.pdf"
        echo "- <orignal_name>__intern.<ext> --> <original_name>__intern.pdf"
        echo "- <orignal_name>__public.<ext> --> <original_name>.pdf"
        echo ""
        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_filename="$1"

    # export simplify input
    echo "export (simplified) versions of the input"
    export_dir="export/"
    mkdir -p "$export_dir"

    file_fullname="$(basename "$param_filename")"
    file_ext="${file_fullname##*.}"
    file_name="${file_fullname%.*}"

    file_geheim_local="${file_name}__geheim.${file_ext}"
    file_intern_local="${file_name}__intern.${file_ext}"
    file_public_local="${file_name}__public.${file_ext}"

    file_geheim="${export_dir}${file_geheim_local}"
    file_intern="${export_dir}${file_intern_local}"
    file_public="${export_dir}${file_public_local}"

    echo "- copy input       --> ${export_dir}...__geheim.${file_ext}"
    cp "$param_filename" "$file_geheim"
    if [ $? -ne 0 ]; then return -2; fi

    echo "- remove secrets   --> ${export_dir}...__intern.${file_ext}"
    sed_parameters="$(_pandoc_meeting_helper geheim)"
    if [ $? -ne 0 ]; then return -3; fi
    sed $sed_parameters "$file_geheim" > "$file_intern"
    if [ $? -ne 0 ]; then return -3; fi

    echo "- remove internals --> ${export_dir}...__public.${file_ext}"
    sed_parameters="$(_pandoc_meeting_helper intern)"
    if [ $? -ne 0 ]; then return -4; fi
    sed $sed_parameters "$file_intern" > "$file_public"
    if [ $? -ne 0 ]; then return -4; fi

    # compare inputs
    echo ""
    echo "compare exported inputs"

    if diff --brief "$file_geheim" "$file_intern" > /dev/null; then
        echo "- remove secret   input"
        rm "$file_geheim"
    else
        echo "- keep   secret   input"
    fi
    if [ $? -ne 0 ]; then return -5; fi

    if diff --brief "$file_intern" "$file_public" > /dev/null; then
        echo "- remove internal input"
        rm "$file_intern"
    else
        echo "- keep   internal input"
    fi
    if [ $? -ne 0 ]; then return -5; fi

    # convert inputs
    echo ""
    echo "convert exported inputs"
    (
        cd "$export_dir"
        if [ $? -ne 0 ]; then return -6; fi
        if [ -f "$file_geheim_local" ]; then
            echo "- convert secret   input"
            pandoc_meeting_geheim "$file_geheim_local"
            if [ $? -ne 0 ]; then return -6; fi
        fi

        if [ -f "$file_intern_local" ]; then
            echo "- convert internal input"
            pandoc_meeting_intern "$file_intern_local"
            if [ $? -ne 0 ]; then return -6; fi
        fi

        if [ -f "$file_public_local" ]; then
            echo "- convert public   input"
            pandoc_meeting_public "$file_public_local"
            if [ $? -ne 0 ]; then return -6; fi
        fi
    )

    # rename public output
    echo ""
    echo "rename public output"
    old_name="${export_dir}${file_name}__public.pdf"
    new_name="${export_dir}${file_name}.pdf"
    if [ -f "$old_name" ]; then
        mv "$old_name" "$new_name"
    else
        echo "missing file"
        echo "($old_name)"
        return -7
    fi

    # done
    echo ""
    echo "done :-)"
}


# 2025 02 12
function multimedia_pdf_from_markdown() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<template> [variable-name]]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs at 1-3 parameters"
        echo "     #1: document name        (e.g. memo.md)"
        echo "    [#2:]user template name   (e.g. roboag for roboag.latex)"
        echo "    [#3:]name of pandoc variable to be set"
        echo "The output file will have pdf as extension."
        echo "  (e.g. memo.pdf)"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_filename="$1"
    param_template="default"
    if [ "$2" != "" ]; then
        param_template="$2"
    fi
    param_variable=""
    if [ "$3" != "" ]; then
        if [ "$3" != "${3//[[:space:]]/}" ]; then
            echo "Variable name (parameter 3) contains spaces"
            echo "($3)"
            return -2
        fi
        param_variable="--variable=$3"
    fi

    # check if file exists
    if [ ! -e "$param_filename" ]; then
        echo "$FUNCNAME: file \"$param_filename\" does not exist."
        return -3
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
        return -4
    fi

    # call pandoc
    tmp="$(basename "$param_filename")"
    out_file="${tmp%.*}.pdf"
    echo "pandoc  ${param_variable} --template=\"$template\" -o \"$out_file\" \"$param_filename\""
    pandoc ${param_variable} --template="$template" -o "$out_file" "$param_filename"
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

# 2025 02 12
function _pandoc_template_helper() {

    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <template> <filename> [<variable-name>]"
        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2-3 parameters"
        echo "     #1: template name        (e.g. simple)"
        echo "     #2: document name        (e.g. memo.md)"
        echo "    [#3:]name of pandoc variable to be set"
        echo "This function is calling multimedia_pdf_from_markdown:"
        echo "    \$ multimedia_pdf_from_markdown \"#2\" \"#1\" \"#3\""
        return
    fi

    param_template="$1"
    param_filename="$2"
    param_variable="$3"

    if [ "$param_template" == "" ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    funcname="pandoc_$param_template"

    # print help
    if [ "$param_filename" == "-h" ]; then
        echo "$funcname <filename> [<variable-name>]"
        return
    fi
    if [ "$param_filename" == "--help" ]; then
        echo "$funcname needs 1-2 parameters"
        echo "     #1: document name        (e.g. memo.md)"
        echo "    [#2:]name of pandoc variable to be set"
        echo "This function is calling multimedia_pdf_from_markdown:"
        echo "    \$ multimedia_pdf_from_markdown \"#1\" $param_template \"#2\" "
        return
    fi

    # check parameter
    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        echo "$funcname: Parameter Error."
        $FUNCNAME "$param_template" --help
        return -1
    fi

    if [ ! -e "$param_filename" ]; then
        echo "$funcname: file \"$param_filename\" does not exist."
        return -1
    fi

    echo -n "multimedia_pdf_from_markdown" && \
      echo " \"$param_filename\" $param_template $param_variable"
    multimedia_pdf_from_markdown \
      "$param_filename" "$param_template" "$param_variable"
}
