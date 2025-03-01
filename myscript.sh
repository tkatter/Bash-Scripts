#! /bin/bash

lines=$(ls -lh $1 | wc -l)

if [ $# -ne 1 ]
then
    /usr/bin/echo "This script requires exactly one directory path passed to it."
    /usr/bin/echo "Please try again."
    exit 1
fi

/usr/bin/echo "You have $(($lines-1)) objects in the $1 directory."
