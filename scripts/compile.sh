#!/usr/bin/env bash

MAIN=$JANDER_MAIN
BUILD=$JANDER_BUILD

elm make ${BUILD}/${MAIN} \
    --output ${BUILD}/${MAIN%.*}.js
