#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/access-form-group/
# How to grant office access to a form group
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
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.rooms.docusign.com"

#ds-snippet-start:Rooms8Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms8Step2


#ds-snippet-start:Rooms8Step3
# Create a temporary file to store the response
response=$(mktemp /tmp/response-rooms.XXXXXX)
echo ""
echo "Getting an Office ID..."
Status=$(
    curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/offices \
    "${Headers[@]}" \
    --output ${response}
)

OFFICE_ID=$(cat $response | grep officeId | sed 's/.*\"officeId\"://' | sed 's/,".*//')

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

request_data=$(mktemp /tmp/request-rooms-008.XXXXXX)
#ds-snippet-end:Rooms8Step3

# Get a form group ID from the file ./config/FORM_GROUP_ID
#ds-snippet-start:Rooms8Step4
if [ -f "config/FORM_GROUP_ID" ]; then
    FORM_GROUP_ID=$(cat config/FORM_GROUP_ID)
else

    echo " Form group ID is needed. Please run step 7 - Create a form group..."
    exit 0

fi
#ds-snippet-end:Rooms8Step4


response=$(mktemp /tmp/request-rooms-008step4req.XXXXXX)
echo ""
echo "Call the Rooms API..."

#ds-snippet-start:Rooms8Step5
Status=$(
    curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/$FORM_GROUP_ID/grant_office_access/${OFFICE_ID} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}
)
#ds-snippet-end:Rooms8Step5


if [[ "$Status" -ne "204" ]]; then
    echo ""
    echo "Error: Unable to grant office access to a form group"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response status code: $Status "
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"
