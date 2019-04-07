#!/bin/sh
# This script checks if the AGPL license header is present in all files
# usage: $ ./licenseHeaderCheck.sh path/to/LICENSE_HEADER

if [ $# -eq 0 ]
  then
    echo "Provide a path to the license header to look for"
	exit 1
fi

IFS=$'\n'	# don't break on words, but lines
all_lines=`cat $1`

echo "Looking for files which are missing the license header"

for line in $all_lines; do
	# Check all *.gd files if they contain the line from the license header
	findings=$(find . -name "*.gd" | xargs grep -r -L $line | wc -l)
	if [ "$findings" -gt "0" ]; then
		echo "The following license header line is missing:"
		echo $line
		echo ""
		echo "It is missing in the following files:"
		find . -name "*.gd" | xargs grep -r -L $line
		echo ""
		exit 1
	fi
done

echo "Success - all files contain the license header!"
