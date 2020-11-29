#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/activate-clickwrap
# How to activate a clickwrap
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

# Setup variables for full code example
VersionNumber="1"

# Get a ClickWrap ID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo "ClickWrap ID is neded. Please run step 1 - Create ClickWrap..."
    exit 0
fi

# - Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \ 
    '--header' "Accept: application/json" \ 
    '--header' "Content-Type: application/json")

# - Construct your clickwrap JSON body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw.XXXXXX)
printf \
    '{
        "status" : "active" 
    }' >$request_data

# a) Make a POST call to the clickwraps endpoint to activate the clickwrap for an account
# b) Display the JSON structure of the created clickwrap

# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)

curl --header "Authorization: Bearer ${oAuthAccessToken}" \
    --header "Content-Type: application/json" \
    --data-binary @${request_data} \
    --request PUT https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps/${clickwrap_id}/versions/${VersionNumber} \
    --output $response

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"
