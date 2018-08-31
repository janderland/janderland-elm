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


TASKS=( "link"  "generate" "compile" )


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
