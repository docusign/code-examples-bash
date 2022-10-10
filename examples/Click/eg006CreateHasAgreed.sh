#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/get-create-has-agreed
# Checks if a user has agreed to a clickwrap and returns a response with the agreement URL.
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
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")


# Step 3. Construct the request body
# Create a temporary file to store the JSON body

echo "Please input a client User Id (your own unique identifier) for the clickwrap: "
read client_user_id
echo "Please input a full name: "
read full_name
echo "Please input an email address: "
read email_address
echo "Please input a company name: "
read company_name
echo "Please input a job title: "
read title

request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
printf \
    '
    {
  "clientUserId": "'"$client_user_id"'",
  "documentData": {
    "fullName": "'"$full_name"'",
    "email": "'"$email_address"'",
    "company": "'"$company_name"'",
    "title": "'"$title"'",
    "date": "'"$(date -I)"'"
  }
  }' >$request_data

# Step 4. Call the Click API
# a) Make a POST call to the agreements endpoint to dynamically generate 
# b) Display the returned JSON structure of the response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)

curl --request POST https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps/${clickwrap_id}/agreements \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}


message=`cat $response | grep message | sed 's/.*\"message\":\"//'`
echo "the message is: $message"

if [[ "${message}" == *"There are no active versions for clickwrapId"* ]] ;then
echo "Clickwrap needs to be activated. Please run step 2 - Activate Clickwrap"

else
echo ""
echo "Response:"
cat $response
echo ""


fi


# Remove the temporary file
rm "$response"
