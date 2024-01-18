#!/bin/bash

#***************************[help]********************************************
# 2023 10 06

function multimedia_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME  #no help"
    echo ""
    echo "pdf"
    echo -n "  "; multimedia_pdf_page_extract -h
    echo -n "  "; multimedia_pdf_images_extract -h
    echo -n "  "; multimedia_pdf_shrink -h
    echo -n "  "; multimedia_pdf_from_markdown -h
    echo "  _multimedia_pdf_from_markdown_create_aliases  #no help"
    echo ""
    echo "images"
    echo -n "  "; multimedia_images_shrink_all -h
    echo -n "  "; multimedia_images_cut -h
    echo ""
    echo "videos"
    echo -n "  "; multimedia_video_info -h
    echo -n "  "; multimedia_video_cut_simple -h
    echo ""
}
