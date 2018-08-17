#!/usr/bin/env bash

MAIN=$JANDER_MAIN
BUILD=$JANDER_BUILD

elm-make ${BUILD}/${MAIN} \
    --warn --output ${BUILD}/${MAIN%.*}.html
