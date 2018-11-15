#!/bin/bash

#***************************[paths and files]*********************************
# 2018 04 01

temp_local_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/"


#***************************[source]******************************************
# 2018 11 15

. ${temp_local_path}scripts/pdf_functions.sh
. ${temp_local_path}scripts/video_functions.sh
. ${temp_local_path}scripts/help.sh
