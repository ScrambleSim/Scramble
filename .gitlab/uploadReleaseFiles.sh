#!/bin/bash
# This script uploads the Scramble export files to Gitlab and saves the resulting
# URLs in a file

# $1 your Gitlab private token
# $2 your Gitlab project ID
# $3 tag name to delete
function deleteRelease {
    curl --request DELETE --header "PRIVATE-TOKEN: $1" "https://gitlab.com/api/v4/projects/$2/releases/$3"
}

# $1 your Gitlab private token
# $2 filename you want to upload
# $3 Gitlab project ID
# Returns:
# UPLOAD_RESPONSE the json from Gitlabs REST API
# URL the URL the uploaded file can be found at
# ALT the name of the uploaded file
function uploadFile {
    UPLOAD_RESPONSE=$(curl --request POST --header "PRIVATE-TOKEN: $1" --form "file=@$3" https://gitlab.com/api/v4/projects/$2/uploads -s)

    URL="http://gitlab.com/ScrambleSim/Scramble"$(echo $UPLOAD_RESPONSE | jq -r ".url")
    ALT=$(echo $UPLOAD_RESPONSE | jq -r ".alt")
}

PROJECT_ID=9172002

uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-client-linux.zip" 
LINUX_CLIENT_FILENAME=$ALT
LINUX_CLIENT_URL=$URL

uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-server-linux.zip" 
LINUX_SERVER_FILENAME=$ALT
LINUX_SERVER_URL=$URL


uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-client-mac.zip" 
MAC_CLIENT_FILENAME=$ALT
MAC_CLIENT_URL=$URL

uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-server-mac.zip" 
MAC_SERVER_FILENAME=$ALT
MAC_SERVER_URL=$URL


uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-client-windows.zip" 
WINDOWS_CLIENT_FILENAME=$ALT
WINDOWS_CLIENT_URL=$URL

uploadFile "$PRIVATE_TOKEN" "$PROJECT_ID" "Scramble-server-windows.zip" 
WINDOWS_SERVER_FILENAME=$ALT
WINDOWS_SERVER_URL=$URL

RELEASE_JSON_TEMPLATE='{
    "name": "%s",
    "tag_name": "%s",
    "description": "%s",
    "assets": {
	"links": [
	    {
		"name": "%s",
		"url": "%s"
	    },
	    {
		"name": "%s",
		"url": "%s"
	    },
	    {
		"name": "%s",
		"url": "%s"
	    },
	    {
		"name": "%s",
		"url": "%s"
	    },
	    {
		"name": "%s",
		"url": "%s"
	    },
	    {
		"name": "%s",
		"url": "%s"
	    }
	]
    }
}'

RELEASE_DESCRIPTION='🎉 Enjoy the lastest Scramble release 🎉'

RELEASE_DATA_JSON=$(printf "$RELEASE_JSON_TEMPLATE" \
"Scramble release $VERSION" \
"$VERSION" \
"$RELEASE_DESCRIPTION" \
"$LINUX_CLIENT_FILENAME" "$LINUX_CLIENT_URL" \
"$LINUX_SERVER_FILENAME" "$LINUX_SERVER_URL" \
"$MAC_CLIENT_FILENAME" "$MAC_CLIENT_URL" \
"$MAC_SERVER_FILENAME" "$MAC_SERVER_URL" \
"$WINDOWS_CLIENT_FILENAME" "$WINDOWS_CLIENT_URL" \
"$WINDOWS_SERVER_FILENAME" "$WINDOWS_SERVER_URL" \
)

echo $RELEASE_DATA_JSON

curl --header 'Content-Type: application/json' \
  --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
  --data "$RELEASE_DATA_JSON" \
  --request POST \
  "https://gitlab.com/api/v4/projects/$PROJECT_ID/releases" \

