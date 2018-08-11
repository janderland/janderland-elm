#!/usr/bin/env bash


DEST="build"
ORIG="source"
FILES=( ${ORIG}/* )



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
    rm -f $(basename $FILE)
    if ! ln -s ../${FILE} $(basename $FILE)
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

