#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/create-active-user/
# How to create a new user with active status
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
#ds-snippet-start:Admin13Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin13Step2

#ds-snippet-start:Admin13Step3
response=$(mktemp /tmp/response-oa.XXXXXX)
Status=$(curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/planItems \
"${Headers[@]}" \
--output ${response})

echo "Results from the GET request:"
cat $response
echo ""

PLAN_ID=$(cat $response | sed 's/,/\n/g' | grep plan_id | sed 's/.*\"plan_id\":\"//g' | sed 's/\".*//g')
SUBSCRIPTION_ID=$(cat $response | sed 's/,/\n/g' | grep subscription_id | sed 's/.*\"subscription_id\":\"//g' | sed 's/\".*//g')
#ds-snippet-end:Admin13Step3

request_data=$(mktemp /tmp/request_data-oa.XXXXXX)

read -p "Please enter the account name for the new account: " ACCOUNT_NAME
read -p "Please enter the email address for the new account: " EMAIL_ADDRESS
read -p "Please enter the first name for the new account: " FIRST_NAME
read -p "Please enter the last name for the new account: " LAST_NAME

#ds-snippet-start:Admin13Step4
# The country code value is set to "US" for the developer environment
# In production, set the value to the code for the country of the target account
printf \
'{
    "subscriptionDetails": {
        "id": "'${SUBSCRIPTION_ID}'",
		"planId": "'${PLAN_ID}'",
		"modules": []
    },
    "targetAccount": {
        "name": "'${ACCOUNT_NAME}'",
        "countryCode": "US",
        "admin": {
            "email": "'${EMAIL_ADDRESS}'",
            "firstName": "'${FIRST_NAME}'",    
            "lastName": "'${LAST_NAME}'",
            "locale": "en"
        }
    }
}
' >>$request_data
#ds-snippet-end:Admin13Step4

# Create the new account
#ds-snippet-start:Admin13Step5
response=$(mktemp /tmp/response-oa.XXXXXX)
Status=$(curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/assetGroups/accountCreate \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})
#ds-snippet-end:Admin13Step5

echo "Results from the create account method:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
rm "$request_data"
echo ""
echo "Done."
