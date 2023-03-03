#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/assign-form-group/
# How to assign a form to a form group
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

IFS=$'\n'

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
Status=$(curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_libraries "${Headers[@]}" --output ${response})

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

declare -A form_name_to_id_map
form_names=()
FORM_ID=''

FORMS_LIBRARY_ID=$(cat $response | grep formsLibraryId | sed 's/.*formsLibraryId\":"//' | sed 's/\".*//')

# Call the Rooms API to look up a list of form IDs for the given forms library
Status=$(curl -s -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_libraries/${FORMS_LIBRARY_ID}/forms "${Headers[@]}" --output ${response})

if [[ "$Status" -gt "200" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

form_name=`cat $response | grep -o -P '(?<=name\":\").*?(?=\")'`
form_ids=`cat $response | grep -o -P '(?<=libraryFormId\":).*?(?=\,)'`

arr_form_ids=($form_ids)
form_count=$(echo "$form_name" | grep -c '^')

if [ "$form_count" -eq "1" ]; then
    FORM_ID=$form_ids
else
    echo ""
    PS3='Select a form by the form name: '
    IFS=$'\n'
    select form in $form_name; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$form_count" ]; then
            FORM_ID=${arr_form_ids[$REPLY-1]//\"/}
            break
        fi
    done
fi

echo ""
echo "FORM_ID: " $FORM_ID
echo ""
# Step 3 End

# Call the Rooms API to look up a list of form group IDs
Status=$(curl -w '%{http_code}' --request GET ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups "${Headers[@]}" --output ${response})

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

form_group_name=`cat $response | grep -o -P '(?<=name\":\").*?(?=\")'`

form_group_ids=`cat $response | grep -o -P '(?<=formGroupId\":).*?(?=\,)'`

arr_form_group_ids=($form_group_ids)
form_group_count=$(echo "$form_group_name" | grep -c '^')

if [ -z "$form_group_name" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "Form group ID is needed. Please run step 7 - Create a form group..."
    exit 0
elif [ "$form_count" -eq "1" ]; then
    FORM_GROUP_ID=$form_group_ids
else
    echo ""
    PS3="Select a form group: "
    IFS=$'\n'
    select form_group in $form_group_name; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$form_group_count" ]; then
            FORM_GROUP_ID=${arr_form_group_ids[$REPLY-1]//\"/}
            break
        fi
    done
fi

echo ""
echo "FORM_GROUP_ID: " $FORM_GROUP_ID
echo ""

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
Status=$(curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/${FORM_GROUP_ID}/assign_form "${Headers[@]}" --data-binary @${request_data} --output ${response})
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
