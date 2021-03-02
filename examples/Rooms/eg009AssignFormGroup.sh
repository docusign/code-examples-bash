#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/assign-form-group/
# How to assign a form to a form group
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
# Call the Rooms API to look up your forms library ID
Status=$(curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_libraries \
    "${Headers[@]}" \
    --output ${response})

if [[ "$Status" -gt "200" ]]; then
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

FORMS_LIBRARY_ID=$(cat $response | grep formsLibraryId | sed 's/.*formsLibraryId\":"//' | sed 's/\".*//')

# Call the Rooms API to look up a list of form IDs for the given forms library
Status=$(curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_libraries/${FORMS_LIBRARY_ID}/forms \
    "${Headers[@]}" \
    --output ${response})

if [[ "$Status" -gt "200" ]]; then
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

FORM_ID=$(cat $response | grep libraryFormId | sed 's/.*libraryFormId\":"//' | sed 's/\".*//')
# Step 3 End


# Get a form group ID from the file ./config/FORM_GROUP_ID
# Step 4 Start
if [ -f "config/FORM_GROUP_ID" ]; then
    FORM_GROUP_ID=$(cat config/FORM_GROUP_ID)
else
# Step 4 End
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


# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-rooms-008.XXXXXX)

# Step 5 Start
printf \
    '
{
  "formId": "'"${FORM_ID}"'",
}' >>$request_data
# Step 5 End

# Create a temporary file to store the response
response=$(mktemp /tmp/response-rooms.XXXXXX)

# Step 6 Start
Status=$(curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/${FORM_GROUP_ID}/assign_form \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
# Step 6 End

if [[ "$Status" -gt "204" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response: No JSON response body returned when saving a form to the form group"
echo ""
