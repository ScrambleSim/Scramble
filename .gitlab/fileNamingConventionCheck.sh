#!/bin/bash
# This script checks if all files with a certain extension
# conform to the naming conventions

declare all_file_names=`find . -name "*.gd" -or -name "*.tscn" -type f -exec basename {} \;`
declare findings=0

echo "The following files do not conform to the naming convention:"
for file_name in $all_file_names; do
    if ! [[ $file_name =~ ^[a-z0-9_]+.[a-z]+$ ]]; then
        echo "$(find . -name $file_name)"

        findings+=1
    fi
done

if [ $findings -gt 0 ]; then
    echo "Please make sure they are all lowercase and seperated by underscores."
    exit 1
fi

