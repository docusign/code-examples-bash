#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/add-form-to-room
# How to add forms to a room
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

base_path="https://demo.docusign.net/restapi"
room_id=$(cat config/ROOM_ID)

# Construct your API headers
#ds-snippet-start:Rooms4Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms4Step2

# Get a Room ID
if [ -f "config/ROOM_ID" ]; then
    room_id=$(cat config/ROOM_ID)
else
    echo "" Room ID is needed. Please run step 1 or 2...
    exit 0
fi

# Get a Library ID
# Create a temporary file to store the response
response=$(mktemp /tmp/response-rms.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/form_libraries" \
    "${Headers[@]}" \
    --output ${response})

cat $response
form_library_id=$(cat $response | grep formsLibraryId | sed 's/.*\"formsLibraryId\"://' | sed 's/,.*//' | sed 's/\"//g')

# Get a Library form ID
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/form_libraries/${form_library_id}/forms" \
    "${Headers[@]}" \
    --output ${response})

cat $response
library_form_id=$(cat $response | grep libraryFormId | sed 's/.*\"libraryFormId\"://' | sed 's/,.*//' | sed 's/\"//g')

# Remove the temporary file
rm "$response"


# Create a temporary file to store the request body and response
request_data=$(mktemp /tmp/request-rms-001.XXXXXX)
response=$(mktemp /tmp/response-rms.XXXXXX)
# Construct the request body for adding a form
#ds-snippet-start:Rooms4Step3
printf \
    '{
        "formId":"'"$library_form_id"'",
    }' >$request_data
#ds-snippet-end:Rooms4Step3

# a) Call the Rooms API
# b) Display the JSON response
#ds-snippet-start:Rooms4Step4
Status=$(curl -w '%{http_code}' -i --request POST "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms/${room_id}/forms" \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Rooms4Step4

# If the Status code returned is greater than 201 (OK/Accepted), display an error message along with the API response
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Posting the new room has failed."
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"
