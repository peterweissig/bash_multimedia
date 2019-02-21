#!/bin/bash

#***************************[check if already sourced]************************
# 2018 11 30

if [ "$SOURCED_BASH_MULTIMEDIA" != "" ]; then

    return
    exit
fi

export SOURCED_BASH_MULTIMEDIA=1


#***************************[paths and files]*********************************
# 2018 11 17

temp_local_path="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"


#***************************[source]******************************************
# 2019 02 20

. ${temp_local_path}scripts/pdf_functions.sh
. ${temp_local_path}scripts/image_functions.sh
. ${temp_local_path}scripts/video_functions.sh
. ${temp_local_path}scripts/help.sh
