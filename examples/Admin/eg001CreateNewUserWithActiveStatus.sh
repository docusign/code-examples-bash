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

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Step 3. Construct the request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)

printf \
'{
  "user_name": "Example User Name",
  "first_name": "Example",
  "last_name": "Name",
  "email": "examplename42@orobia.net",
  "auto_activate_memberships": true,
  "accounts": [
    {
      "id": ${ACCOUNT_ID},
      "permission_profile": {
        "id": xxxxxxx,
      },
      "groups": [
        {
          "id": xxxxxxx,
        }
      ]
    }
  ]
}
' >>$request_data

# Call the DocuSign Admin API
response=$(mktemp /tmp/response-oa.XXXXXX)
curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response}

echo ''
echo 'Response:'
echo ''
cat $response
echo ''

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""

echo "eg001CreateNewUserWithActiveStatus.sh - Work in progress..."
