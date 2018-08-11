#!/usr/bin/env bash


CONFIG=config.env


if [ -e $CONFIG ]
then
    # Load configuration variables into current scope
    source $CONFIG

    # Export all the variable so they are available in
    # child processes.
    export $(cut -d= -f1 $CONFIG)
else
    echo "Config file \"${CONFIG}\" is missing"
    echo
    exit 1
fi
