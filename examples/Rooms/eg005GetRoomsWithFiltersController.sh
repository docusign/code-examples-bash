#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/get-room-with-filters/
# How to get a room with filters
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

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Set your filtering parameters
# Calculate the past and current query parameters and use the ISO 8601 format.
if date -v -10d &>/dev/null; then
    # Mac
    # past=`date -v -10d '+%Y-%m-%dT%H:%M:%S%z'`
    past=$(date -v -10d '+%Y-%m-%d')
    # Set the date 1 day forward to account for changes made today
    # current=`date -v +1d '+%Y-%m-%dT%H:%M:%S%z'`
    current=$(date -v +1d '+%Y-%m-%d')
else
    # Not a Mac
    # past=`date --date='-10 days' '+%Y-%m-%dT%H:%M:%S%z'`
    past=$(date --date='-10 days' '+%Y-%m-%d')
    # Set the date 1 day forward to account for changes made today
    # current=`date --date='+1 days' '+%Y-%m-%dT%H:%M:%S%z'`
    current=$(date --date='+1 days' '+%Y-%m-%d')
fi

# Call the v2 Rooms API
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms?fieldDataChangedStartDate=${past}&fieldDataChangedEndDate=${current}" \
    "${Headers[@]}" \
    --output ${response}

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
