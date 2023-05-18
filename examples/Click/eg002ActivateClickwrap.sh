#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/activate-clickwrap
# How to activate a Clickwrap
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

# Setup variables for full code example
VersionNumber="1"

# Get a ClickwrapID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo ""
    echo "Clickwrap ID is needed. Please run step 1 - Create Clickwrap..."
    exit 0
fi

# Step 2. Construct your API headers
#ds-snippet-start:eSign2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" 
    '--header' "Content-Type: application/json"
    '--header' "Accept: application/json")
#ds-snippet-end:eSign2Step2

# Construct your Clickwrap JSON body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw.XXXXXX)
#ds-snippet-start:eSign2Step3
printf \
    '{
        "status" : "active" 
    }' >$request_data
#ds-snippet-end:eSign2Step3

# a) Make a POST call to the Clickwraps endpoint to activate the Clickwrap for an account
# b) Display the JSON structure of the created Clickwrap

# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)

#ds-snippet-start:eSign2Step4
curl --request PUT https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps/${clickwrap_id}/versions/${VersionNumber} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}
#ds-snippet-end:eSign2Step4

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"
