#!/bin/bash
# Turns all files per platform into a zip

ls -la

# $1 type
# $2 platform
function zipRelease {
    zip -r "Scramble-client-$1.zip" "Scramble-client-$1".*
    zip -r "Scramble-server-$1.zip" "Scramble-server-$1".*
}

zipRelease "linux"
zipRelease "mac"
zipRelease "windows"

