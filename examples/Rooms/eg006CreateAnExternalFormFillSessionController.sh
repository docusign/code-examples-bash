#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/external-form-fill
# How to create an external form fillable session
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

# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

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

# Construct your request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-rooms.XXXXXX)
printf \
    '{
        "roomId": '$room_id',
        "formIds": ["'$library_form_id'"],
        "xFrameAllowedUrl": "https://iframetester.com"
    }' >$request_data

# Call the v2 Rooms API
# Create a temporary file to store the response
response=$(mktemp /tmp/response-rooms.XXXXXX)

curl --request POST https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/external_form_fill_sessions \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}

echo ""
echo "URL to be Embedded:"
cat $response
echo ""
echo ""

embed_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`
redirect_url="https://iframetester.com/?url=${embed_url}"
echo ""

echo "The embedded form URL is ${redirect_url}"
echo ""
echo "Attempting to automatically open your browser..."

if which xdg-open &> /dev/null  ; then
  xdg-open "$redirect_url"
elif which open &> /dev/null    ; then
  open "$redirect_url"
elif which start &> /dev/null   ; then
  start "$redirect_url"
fi


# Remove the temporary files
rm "$request_data"
rm "$response"
