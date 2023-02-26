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

for form in `cat $response | jq -c '.forms[]'`; do
    form_id=`echo $form | jq -c '.libraryFormId' | tr -d '"'`
    form_name=`echo $form | jq -c '.name' | tr -d '"'`

    form_name_to_id_map[$form_name]=$form_id
    form_names+=($form_name)
done

echo ""
echo "Select a form by the form name:"
i=1
for form_name in "${form_names[@]}"; do
    echo "$i) $form_name"
    i=$((i+1))
done

is_valid_num=false
while [[ $is_valid_num == false ]]; do
    echo ""

    read -p "Select a form: " chosen_form

    if [[ $chosen_form -lt 1 || $chosen_form -gt ${#form_names[@]} ]]; then
        echo "Please, pick one of the suggested options."
    else
        is_valid_num=true
        chosen_form=$((chosen_form-1))
        FORM_ID=${form_name_to_id_map[${form_names[chosen_form]}]}
    fi
done
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

FORM_GROUP_ID=""

# Check if form group id was selected. If no id's where picked - ask user to create a new one
if [ -z "$response" ]; then
    echo " Form group ID is needed. Please run step 7 - Create a form group..."
    exit 0
else
    i=1
    echo "Select a form group:"

    for line in `cat $response | jq -c '.formGroups[].name'`; do
        echo -n "$i) "
        echo $line | tr -d '"'
        i=$((i+1))
    done

    i=$((i-1))

    is_valid_num=false
    while [[ $is_valid_num == false ]]; do
        read -p "Select a form group: " chosen_form_group

        if [[ $chosen_form_group -lt 1 || $chosen_form_group -gt $i ]]; then
            echo "Please, pick one of the suggested options."
        else
            is_valid_num=true
            i=$((i-1))
            FORM_GROUP_ID=$(cat $response | jq -c --argjson index $i '.formGroups[$index].formGroupId')
        fi
    done
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
Status=$(curl -w '%{http_code}' --request POST ${base_path}/restapi/v2/accounts/${API_ACCOUNT_ID}/form_groups/${FORM_GROUP_ID//\"/}/assign_form "${Headers[@]}" --data-binary @${request_data} --output ${response})
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
