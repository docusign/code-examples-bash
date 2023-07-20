#!/bin/bash
# This shows an organization admin how to delete a user's data from one or more accounts.
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Note: Substitute these values with your own
# Obtain your OAuth token
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"
ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Construct your API headers
#ds-snippet-start:Admin10Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin10Step2

response=$(mktemp /tmp/response-oa.XXXXXX)
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)

# Get user information
echo "Please input the email address of the user whose data will be deleted. Note that this email address should be associated with a user that has been closed for at least 24 hours."
read EMAIL_ADDRESS

curl -w '%{http_code}' -i --request GET "${base_path}/v2.1/organizations/${ORGANIZATION_ID}/users/dsprofile?email=${EMAIL_ADDRESS}" \
    "${Headers[@]}" \
    --output ${response}


USER_ID=$(cat $response | sed 's/}]}/\n/' | grep users | sed 's/.*\"id\"://' | sed 's/,".*//')
ACCOUNT_ID=$(cat $response | sed 's/}]}/\n/' | grep memberships | sed 's/.*\"account_id\"://' | sed 's/,".*//')

# Construct the request body
#ds-snippet-start:Admin10Step3
printf \
'{
  "user_id": '${USER_ID}',
  "memberships": [{
    "account_id": '${ACCOUNT_ID}',
  }]
}
' >>$request_data
#ds-snippet-end:Admin10Step3

#Delete user info from an organization
#ds-snippet-start:Admin10Step4
curl -w '%{http_code}' -i --request POST "${base_path}/v2/data_redaction/organizations/${ORGANIZATION_ID}/user" \
  "${Headers[@]}" \
  --data-binary @${request_data} \
  --output ${response}
#ds-snippet-end:Admin10Step4

echo ""
echo "Response: "
echo ""
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""
