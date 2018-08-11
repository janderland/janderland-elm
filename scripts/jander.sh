#!/usr/bin/env bash

TASKS=( "link"  "generate" "compile" )


source scripts/loadConfig.sh


for TASK in "${TASKS[@]}"
do
    # Print task name in uppercase
    echo $TASK | awk '{print toupper($0)}'

    # Run task script
    scripts/${TASK}.*
    CODE=$?

    echo

    # If task failed, exit with the task's
    # exit code.
    if [ $CODE -ne 0 ]
    then
        exit $CODE
    fi
done
