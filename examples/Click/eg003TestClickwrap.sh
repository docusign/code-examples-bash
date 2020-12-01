#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/test-clickwrap
# How to test a clickwrap
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

# Get a ClickWrap ID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo ""
    echo "ClickWrap ID is neded. Please run step 1 and 2 - Create and Activate ClickWrap..."
    exit 0
fi

# Check that Clickwrap is activated
echo ""
echo "Check that Clickwrap is activated..."

response=$(mktemp /tmp/response-cw.XXXXXX)
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json")

Status=$(curl --request GET https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps/${clickwrap_id}/ \
    "${Headers[@]}" \
    --output ${response})

clickwrap_status=$(cat $response | grep status | sed 's/ //g' | sed 's/.*\"status\":\"//' | sed 's/\",.*//')

if [ $clickwrap_status != "active" ]; then
    echo ""
    echo "ClickWrap ID is not activated. Please run step 2 - Activate ClickWrap..."
    exit 0
fi

environment="demo"
test_url="https://developers.docusign.com/click-api/test-clickwrap?a=${account_id}&cw=${clickwrap_id}&eh=${environment}"

echo ""
printf "The clickwrap tester URL is ${test_url}\n"
printf "Opening the clickwrap tester URL directly in your browser...\n"
if which xdg-open &>/dev/null; then
    xdg-open "$test_url"
elif which open &>/dev/null; then
    open "$test_url"
elif which start &>/dev/null; then
    start "$test_url"
fi

# Remove the temporary file
rm "$response"