#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/retrieve-clickwraps
# How to get a list of Clickwraps
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
account_id=$(cat config/API_ACCOUNT_ID)

# Step 2. Construct your API headers
#ds-snippet-start:Click4Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json")
#ds-snippet-end:Click4Step2

# Step 3. Call the Click API
# a) Make a GET call to the Clickwraps endpoint to retrieve all Clickwraps for an account
# b) Display the JSON structure of the returned Clickwraps
#Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
#ds-snippet-start:Click4Step3
curl --request GET https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps \
    "${Headers[@]}" \
    --output ${response}
#ds-snippet-end:Click4Step3

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary file
rm "$response"
