#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/get-room-with-filters/
# How to get a room with filters
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

# Construct your API headers
#ds-snippet-start:Rooms5Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms5Step2

# Set your filtering parameters
# Calculate the past and current query parameters and use the ISO 8601 format.
#ds-snippet-start:Rooms5Step3
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
#ds-snippet-end:Rooms5Step3

# Call the v2 Rooms API
# Create a temporary file to store the response
#ds-snippet-start:Rooms5Step4
response=$(mktemp /tmp/response-cw.XXXXXX)
curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms?fieldDataChangedStartDate=${past}&fieldDataChangedEndDate=${current}" \
    "${Headers[@]}" \
    --output ${response}
#ds-snippet-end:Rooms5Step4

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
