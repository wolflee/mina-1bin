#!/bin/bash

# Do whatever to simplify the server booting process
#
# The following is just an example:

# binary_name="./<binary file name>"
#
# pid=$(pgrep -f "$binary_name")
# if [ "start" = $1 ]; then
#   if [ -z $pid ]; then
#     $binary_name & echo "App started."
#   else
#     echo "$binary_name(pid:$pid) is already running ..."
#   fi
# elif [ "restart" = $1 ]; then
#   kill -9 $pid
#   $binary_name & echo "App started."
# elif [ "stop" = $1 ]; then
#   echo "killing $binary_name(pid:$pid) ..."
#   kill -9 $pid
# else
#   echo "./run.sh [start|stop]"
# fi
