#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/create-form-group/
# How to create a form group
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

#ds-snippet-start:Rooms7Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms7Step2

# Create a temporary file to store the response
response=$(mktemp /tmp/response-rooms.XXXXXX)


# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-rooms-007.XXXXXX)

#ds-snippet-start:Rooms7Step3
printf \
    '
{
  "name": "Sample Room Form Group",
}' >$request_data
#ds-snippet-end:Rooms7Step3


#ds-snippet-start:Rooms7Step4
Status=$(curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Rooms7Step4

FORM_GROUP_ID=$(cat $response | grep formGroupId | sed 's/.*formGroupId\":"//' | sed 's/\".*//')

# Store FORM_GROUP_ID into the file ./config/FORM_GROUP_ID
echo $FORM_GROUP_ID >./config/FORM_GROUP_ID

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

# Remove the temporary files
rm "$request_data"
rm "$response"
