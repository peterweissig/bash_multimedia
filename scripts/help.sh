#!/bin/bash

#***************************[help]********************************************
# 2025 02 12

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
    echo ""
    echo -n "  "; pandoc_simple -h
    echo -n "  "; pandoc_meeting -h
    echo ""
    echo "images"
    echo -n "  "; multimedia_images_shrink -h
    echo -n "  "; multimedia_images_cut -h
    echo ""
    echo "videos"
    echo -n "  "; multimedia_video_info -h
    echo -n "  "; multimedia_video_cut_simple -h
    echo ""
}
