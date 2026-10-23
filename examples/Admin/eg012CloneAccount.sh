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
#ds-snippet-start:Admin12Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin12Step2

# Get list of asset group accounts for an organization

response=$(mktemp /tmp/response-oa.XXXXXX)
request_data=$(mktemp /tmp/request_data-oa.XXXXXX)

#ds-snippet-start:Admin12Step3
Status=$(curl --request GET ${base_path}/v1/organizations/${ORGANIZATION_ID}/assetGroups/accounts?compliant=true \
"${Headers[@]}" \
--output ${response})
#ds-snippet-end:Admin12Step3

echo ""
echo "Results from the getAssetGroupAccounts method:"
cat $response
echo ""

# Store account names and if there are more than one accounts, let the user choose which one to clone
asset_group_account_names=$(cat $response | sed 's/,/\n/g' | grep accountName | sed 's/.*\"accountName\":\"//g' | sed 's/\".*//g')
accounts_count=$(echo "$asset_group_account_names" | grep -c '^')

if [ "$accounts_count" -eq "1" ]; then
    SOURCE_ACCOUNT_ID=$(cat $response | sed 's/}]}/\n/g' | grep assetGroupAccounts | sed 's/.*\"accountId\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select an account to clone : '
    IFS=$'\n'
    select account_name in $asset_group_account_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$accounts_count" ]; then
            SOURCE_ACCOUNT_ID=$(cat $response | sed 's/.*\"assetGroupAccounts\"://' | sed 's/},/\n/g' | grep $account_name | sed 's/.*\"accountId\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

rm "$response"

read -p "Please enter the name of the new account: " ACCOUNT_NAME
read -p "Please enter the first name of the new account admin: " FIRST_NAME
read -p "Please enter the last name of the new account admin: " LAST_NAME
read -p "Please enter the email address of the new account admin: " EMAIL

#ds-snippet-start:Admin12Step4
# The country code value is set to "US" for the developer environment
# In production, set the value to the code for the country of the target account
printf \
'{
    "sourceAccount": {
        "id": "'${SOURCE_ACCOUNT_ID}'"
    },
    "targetAccount": {
        "name": "'${ACCOUNT_NAME}'",
        "admin": {
            "firstName": "'${FIRST_NAME}'",
            "lastName": "'${LAST_NAME}'",
            "email": "'${EMAIL}'"
        },
        "countryCode": "US"
    }
}
' >>$request_data
#ds-snippet-end:Admin12Step4

# Clone source account into new account
response=$(mktemp /tmp/response-oa.XXXXXX)
#ds-snippet-start:Admin12Step5
Status=$(curl --request POST ${base_path}/v1/organizations/${ORGANIZATION_ID}/assetGroups/accountClone \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})
#ds-snippet-end:Admin12Step5

echo "Results from the cloneAssetGroupAccount method:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
rm "$request_data"
echo ""
echo "Done."
