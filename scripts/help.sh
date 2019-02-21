#!/bin/bash

#***************************[help]********************************************
# 2019 02 20

function multimedia_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "pdf"
    echo -n "  "; multimedia_pdf_page_extract -h
    echo ""
    echo "images"
    echo -n "  "; multimedia_image_shrink_all -h
    echo ""
    echo "videos"
    echo -n "  "; multimedia_video_info -h
    echo -n "  "; multimedia_video_cut_simple -h
    echo ""
}
