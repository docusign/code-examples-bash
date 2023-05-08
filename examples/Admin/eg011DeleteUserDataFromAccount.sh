#!/bin/bash
# This shows an account admin how to delete user data from an account
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
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 end

response=$(mktemp /tmp/response-oa.XXXXXX)
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)

# Get user information
echo "Please enter the user ID of the user whose data will be deleted. Note that this user ID should be associated with a user that has been closed for at least 24 hours."
read USER_ID

# Construct the request body
#Step 3 start
printf \
'{
  "user_id": "'${USER_ID}'"
}
' >>$request_data

#Delete user info from an organization
curl -w '%{http_code}' -i --request POST "${base_path}/v2/data_redaction/accounts/${API_ACCOUNT_ID}/user" \
  "${Headers[@]}" \
  --data-binary @${request_data} \
  --output ${response}

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
