#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/export-room-data
# How to export data from a room
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Get a Room ID
if [ -f "config/ROOM_ID" ]; then
    room_id=$(cat config/ROOM_ID)
else
    echo "" Room ID is neded. Please run step 1 or 2...
    exit 0
fi

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# a) Call the Rooms API
# b) Display JSON response

# Create a temporary file to store the response
response=$(mktemp /tmp/response-rms-001.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request GET https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms/${room_id}/field_data \
    "${Headers[@]}" \
    --output ${response})

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retreive field_set on roomId: $room_id"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
