#!/bin/bash

#***************************[help]********************************************
# 2018 08 24
function multimedia_help() {

    echo ""
    echo "### multimedia_help ###"
    echo ""
    echo "files"
    echo -n "  "; multimedia_filename_clean -h
    echo -n "  "; multimedia_filename_expand -h
    echo ""
    echo "pdf"
    echo -n "  "; multimedia_pdf_page_extract -h
    echo ""
    echo "videos"
    echo -n "  "; multimedia_video_info -h
    echo -n "  "; multimedia_video_cut_simple -h
    echo ""
}
