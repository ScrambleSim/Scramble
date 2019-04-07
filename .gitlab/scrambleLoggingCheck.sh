#!/bin/sh
# Finds files which use Godot's default print() instead of Scramble's Global.log()

matches=$(grep -r -l --exclude='global.gd' --exclude='input_mappings.gd' --exclude='scrambleLoggingCheck.sh' "print(")

if [ "$matches" ]; then
	echo "The following files still contain print():"
	echo ""
	echo "$matches"
	echo ""
	echo "Please use Global.log() instead."
	exit 1
fi

