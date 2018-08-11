#!/usr/bin/env bash

echo "GENERATING"
util/generate.js

echo; echo "COMPILING"
elm-make janderland.elm
