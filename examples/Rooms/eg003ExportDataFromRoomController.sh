#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/export-room-data
# How to export data from a room
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

# Get a Room ID
if [ -f "config/ROOM_ID" ]; then
    room_id=$(cat config/ROOM_ID)
else
    echo " Room ID is needed. Please run step 1 or 2..."
    exit 0
fi

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
#ds-snippet-start:Rooms3Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms3Step2

# a) Call the Rooms API
# b) Display JSON response

# Create a temporary file to store the response
response=$(mktemp /tmp/response-rms-001.XXXXXX)

#ds-snippet-start:Rooms3Step3
Status=$(curl -w '%{http_code}' -i --request GET https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms/${room_id}/field_data \
    "${Headers[@]}" \
    --output ${response})

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retreive field_set on roomId: $room_id"
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
#ds-snippet-end:Rooms3Step3