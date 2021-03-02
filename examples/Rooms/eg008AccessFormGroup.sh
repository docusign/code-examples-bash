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

# Step 2 Start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 End


# Step 3 Start
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
#Step 3 End

# Step 4 Start
# Get a form group ID from the file ./config/FORM_GROUP_ID

if [ -f "config/FORM_GROUP_ID" ]; then
    FORM_GROUP_ID=$(cat config/FORM_GROUP_ID)
else

# response=$(mktemp /tmp/request-rooms-008step4req.XXXXXX)
# Status=$(
#     curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/ \
#     "${Headers[@]}" \
#     --output ${response}
# )
# FORM_GROUP_ID=$(cat $response | grep formGroupId | sed 's/.*\"formGroupId\":"//' | sed 's/",".*//')

    echo " Form group ID is needed. Please run step 7 - Create a form group..."
    exit 0

fi

# Step 4 End



response=$(mktemp /tmp/request-rooms-008step4req.XXXXXX)
echo ""
echo "Call the Rooms API..."

# Step 5 Start
Status=$(
    curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/$FORM_GROUP_ID/grant_office_access/${OFFICE_ID} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}
)
# Step 5 End


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
