#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/retrieve-clickwraps
# How to get a list of clickwraps
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)

# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Step 2. Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json")

# Step 3. Call the Click API
# a) Make a GET call to the clickwraps endpoint to retrieve all clickwraps for an account
# b) Display the JSON structure of the returned clickwraps
#Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
curl --request GET https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps \
    "${Headers[@]}" \
    --output ${response}

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary file
rm "$response"
