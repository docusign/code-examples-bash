#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/get-clickwrap-responses
# How to get clickwrap responses
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

# Get a Clickwrap ID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo ""
    echo "Clickwrap ID is needed. Please run step 1 - Create Clickwrap..."
    exit 0
fi

# Step 2. Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json")

# Step 3. Call the Click API
# a) Make a GET call to the users endpoint to retrieve responses (acceptance) of a specific clickwrap for an account
# b) Display the returned JSON structure of the responses
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)

curl --request GET https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps/${clickwrap_id}/users \
    "${Headers[@]}" \
    --output ${response}

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary file
rm "$response"
