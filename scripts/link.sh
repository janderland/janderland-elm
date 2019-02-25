#!/usr/bin/env bash

# Set the nullglob to make wildcards that
# match nothing result in an empty string
shopt -s nullglob



DEST=$JANDER_BUILD
ORIG=$JANDER_SOURCE
FILES=( ${ORIG}/* assets/* )



# Crash if $ORIG dir doesn't exist

if ! [ -e $ORIG ]
then
  echo "Source dir \"$ORIG\" doesn't exist"
  exit 1
fi



# Exit if there's nothing to link

if [ ${#FILES[@]} -eq 0 ]
then
  echo "No files to link"
  exit 0
fi



# Create $DEST dir

if ! mkdir -p $DEST
then
  echo "Failed to create dir \"$DEST\""
  exit 1
fi



# Move into $DEST dir

cd $DEST



# For every file in $ORIG dir, create a
# link in $DEST dir

for FILE in ${FILES[@]}
do
  LINK=$(basename $FILE)
  rm -f $LINK
  if ! ln -s ../${FILE} $LINK
  then
    echo "Failed to link \"$FILE\""
    exit 1
  fi
done



# Print the number of files linked

COUNT=${#FILES[@]}
if [ $COUNT -ne 1 ]
then
  echo "Linked $COUNT source files"
else
  echo "Linked $COUNT source file"
fi
