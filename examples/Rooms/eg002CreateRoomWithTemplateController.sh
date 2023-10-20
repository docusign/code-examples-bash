#!/bin/bash
# https://developers.docusign.com/docs/rooms-api/how-to/create-room-with-template/
# How to create a room with a template
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

source ./examples/Rooms/lib/utils.sh

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# - Construct your API headers
#ds-snippet-start:Rooms2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Rooms2Step2

# - Retrieve rooms pre-requisite data
# - Retrieve Rooms default role Id

# Create a temporary file to store the response
#ds-snippet-start:Rooms2Step3
request_data=$(mktemp /tmp/request-rmtmp.XXXXXX)

echo ""
echo "Attempting to retrieve default role Id"
echo ""
response=$(mktemp /tmp/response-rmtmp.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/roles" \
    "${Headers[@]}" \
    --output ${response})
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve your account's role settings"
    echo ""
    cat $response
    exit 0
fi
echo ""
echo "Response:"
cat $response
echo ""

# Retrieve the role IDs from the API response and put them in an array.
roleIds=`cat $response | grep -o -P '(?<=roleId\":).*?(?=,")'`
arrRoleIds=($roleIds)

# Get the index of the role based on name and use that index for roleId. 
# Name of the role is 'Default Admin'
roles=`cat $response | grep -o -P '(?<=name\":).*?(?=,)'`
element="Default Admin"


roleId=$(GetRoleId "$roles" "$element" "$roleIds")

# Remove the temporary files
rm "$request_data"
rm "$response"

# Retrieve a Rooms office ID
# Create a temporary file to store the response
request_data=$(mktemp /tmp/request-rmtmp.XXXXXX)

echo ""
echo "Attempting to retrieve default office ID"
echo ""
response=$(mktemp /tmp/response-rmtmp.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/offices" \
    "${Headers[@]}" \
    --output ${response})
#If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve your account's office ids"
    echo ""
    cat $response
    exit 0
fi
echo ""
echo "Response:"
cat $response
echo ""
officeId=$(cat $response | grep officeId | sed 's/.*\"officeId\"://' | sed 's/,.*//')
#ds-snippet-end:Rooms2Step3

# Remove the temporary files
rm "$request_data"
rm "$response"

# - Retrieve a Room template ID
# Create a temporary file to store the response
request_data=$(mktemp /tmp/request-rmtmp.XXXXXX)

echo ""
echo "Attempting to retrieve a room template ID"
echo ""
response=$(mktemp /tmp/response-rmtmp.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/room_templates" \
    "${Headers[@]}" \
    --output ${response})
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve your account's room templates"
    echo ""
    cat $response
    exit 0
fi
echo ""
echo "Response:"
cat $response
echo ""

# Retrieve the room template ID from the API response.
roomTemplateId=$(cat $response | grep roomTemplateId | sed 's/.*\"roomTemplateId\"://' | sed 's/,.*//')
# Remove the temporary files
rm "$request_data"
rm "$response"
# echo $roleId, $officeId, $roomTemplateId

# Construct the JSON body for your room
# Create a temporary file to store the JSON body
#ds-snippet-start:Rooms2Step4
request_data=$(mktemp /tmp/request-rms-001.XXXXXX)
printf \
    '
{
  "name": "Sample Room Creation",
  "roleId": "'"$roleId"'",
  "officeId": "'"$officeId"'",
  "RoomTemplateId": "'"$roomTemplateId"'",
  "transactionSideId": "listbuy",
  "fieldData": {
    "data" : {
     "address1": "123 EZ Street",
     "address2": "unit 10",
     "city": "Galaxian",
     "state": "US-HI",
     "postalCode": "11112",
     "companyRoomStatus": "5",
     "comments": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      }
     }
}' >>$request_data
#ds-snippet-end:Rooms2Step4
# Create a temporary file to store the response
response=$(mktemp /tmp/response-rms-001.XXXXXX)

# a) Call the Rooms API
# b) Display JSON response
#ds-snippet-start:Rooms2Step5
Status=$(curl -w '%{http_code}' -i --request POST https://demo.rooms.docusign.com/restapi/v2/accounts/${account_id}/rooms \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Rooms2Step5
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Posting the new room has failed."
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "roleID: $roleId"
echo "TemplateID: $roomTemplateId"

echo ""
echo "Response:"
cat $response
echo ""

# Save a Room ID to file
roomId=$(cat $response | grep roomId | sed 's/.*\"roomId\"://' | sed 's/,.*//')
echo $roomId >config/ROOM_ID

# Remove the temporary files
rm "$request_data"
rm "$response"
