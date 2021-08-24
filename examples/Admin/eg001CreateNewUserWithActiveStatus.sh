#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/create-active-user/
# How to create a new user with active status
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
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
# Step 2 End

# Step 3. Construct the request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
response=$(mktemp /tmp/response-oa.XXXXXX)

# Get user's data
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/users/profile?email=${SIGNER_EMAIL} \
      "${Headers[@]}" \
      --output ${response}

echo "signer email: " $SIGNER_EMAIL
echo "response: "
cat $response

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Can't get user's data..."
    echo ""
    cat $response
    exit 0
fi

profile_names=$(cat $response | sed 's/}]}/\n/' | sed 's/,/\n/g' | grep permission_profile_name | sed 's/.*\"permission_profile_name\":\"//g' | sed 's/\".*//g')
profiles_count=$(echo "$profile_names" | grep -c '^')

if [ -z "profile_names" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "You must create a permission profile before running this code example"
    exit 1
elif [ "$profiles_count" -eq "1" ]; then
    permission_profile_id=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $profile_names | sed 's/.*\"ds_group_id\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select a permission profile to assign to the new user : '
    IFS=$'\n'
    select permission_profile in $profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$profiles_count" ]; then
            permission_profile_id=$(cat $response | sed 's/}]}/\n/' | grep sed 's/.*\"permission_profiles\"://' | sed 's/},/\n/g' | grep $permission_profile | sed 's/.*\"permission_profile_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

echo ""
echo "Getting DS Groups..."
# Step 4 Start
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/dsgroups \
     "${Headers[@]}" \
     --output ${response})
#Step 4 End

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

# Get group Id
echo ""
echo "Response:"
cat $response
echo ""
group_names=$(cat $response | sed 's/,/\n/g' | grep group_name | sed 's/.*\"group_name\":\"//g' | sed 's/\".*//g')
groups_count=$(echo "$group_names" | grep -c '^')

if [ -z "$group_names" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "You must create a DS Group before running this code example"
    exit 1
elif [ "$groups_count" -eq "1" ]; then
    group_id=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $group_name | sed 's/.*\"group_id\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select a DS Group to assign to the new user : '
    IFS=$'\n'
    select group_name in $group_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$groups_count" ]; then
            group_id=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $group_name | sed 's/.*\"group_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

read -p "Please enter a username for the new user: " USER_NAME
read -p "Please enter the first name for the new user: " FIRST_NAME
read -p "Please enter the last name for the new user: " LAST_NAME
read -p "Please enter an email for the new user: " USER_EMAIL

printf \
'{
  "user_name": \"'${USER_NAME}'\",
  "first_name": \"'${FIRST_NAME}'\",
  "last_name": \"'{LAST_NAME}'\",
  "email": \"'${USER_EMAIL}'\",
  "auto_activate_memberships": true,
  "accounts": [
    {
      "id": \"'${API_ACCOUNT_ID}'\",
      "permission_profile": {
        "id": \"'${permission_profile_id}'\",
      },
      "groups": [
        {
          "id": \"'${group_id}'\",
        }
      ]
    }
  ]
}' >$request_data

# Call the DocuSign Admin API
response2=$(mktemp /tmp/response-oa.XXXXXX)
curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response2}

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Failed to create a new user"
    echo ""
    cat $response2
    exit 0
fi

echo ''
echo 'Response:'
echo ''
cat $response2
echo ''

# Remove the temporary files
rm "$request_data"
rm "$response"
rm "$response2"

echo ""
echo "Done."
echo ""
