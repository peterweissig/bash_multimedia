#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_MULTIMEDIA" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_MULTIMEDIA="$SOURCED_BASH_LAST"


#***************************[paths and files]*********************************
# 2020 12 27

temp_local_path="$(realpath "$(dirname "${BASH_SOURCE}")" )/"


#***************************[source]******************************************
# 2019 02 20

. ${temp_local_path}scripts/pdf_functions.sh
. ${temp_local_path}scripts/image_functions.sh
. ${temp_local_path}scripts/video_functions.sh
. ${temp_local_path}scripts/help.sh
