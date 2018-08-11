#!/usr/bin/env bash

TASKS=( "generate" "compile" )

for TASK in "${TASKS[@]}"
do
    echo $TASK | awk '{print toupper($0)}'

    scripts/${TASK}.*
    CODE=$?

    echo

    if [ $CODE -ne 0 ]
    then
        exit $CODE
    fi
done
