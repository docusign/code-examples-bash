#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/create-active-user/
# How to create a new user with active status
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
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Step 3. Construct the request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
response=$(mktemp /tmp/response-oa.XXXXXX)

# Get user's data
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/users/profile?email=${SIGNER_EMAIL} \
"${Headers[@]}" \
--output ${response}

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Can't get user's data..."
    echo ""
    cat $response
    exit 0
fi

# Get group ID and permission profile ID
group_id=`cat $response | sed 's/.*\"groups\"://' | sed 's/},/\n/g' | sed 's/.*\"id\"://' | sed 's/\".*//g' | sed 's/,//g' | sed -n 2p`
permission_profile_id=`cat $response | sed 's/.*\"permission_profile\"://' | sed 's/},/\n/g' | sed -n 1p |  sed 's/.*\"id\"://' | sed 's/\".*//g' | sed 's/,//g'`

IFS=" "
read -a NAME_ARRAY <<< "$CC_NAME"
echo "First: " ${NAME_ARRAY[0]}
echo "Last: " ${NAME_ARRAY[1]}

printf \
'{
  "user_name": "'"${CC_NAME}"'",
  "first_name": "'"${NAME_ARRAY[0]}"'",
  "last_name": "'"{NAME_ARRAY[1]}"'",
  "email": "'"${CC_EMAIL}"'",
  "auto_activate_memberships": false,
  "accounts": [
    {
      "id": \"'${API_ACCOUNT_ID}'\",
      "permission_profile": {
        "id": \"'${permission_profile_id}'\",
      },
      "groups": [
        {
          "id": \"'${group_id}'\",
        }
      ]
    }
  ]
}
' >>$request_data

# Call the DocuSign Admin API
response2=$(mktemp /tmp/response-oa.XXXXXX)
curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response2}

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Failed to create a new user"
    echo ""
    cat $response
    exit 0
fi

echo ''
echo 'Response:'
echo ''
cat $response2
echo ''

# Remove the temporary files
rm "$request_data"
rm "$response"
rm "$response2"

echo ""
echo "Done."
echo ""
