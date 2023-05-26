#!/bin/bash
# Create eSignature + CLM user with active status
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Construct your API headers
# Step 2 start
#ds-snippet-start:Admin2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin1Step2
# Step 2 end


# Create a temporary file to store the response
response=$(mktemp /tmp/response-admin.XXXXXX)
echo ""
echo "Getting permission profiles..."
# Step 3 Start
#ds-snippet-start:Admin2Step3
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/permission_profiles \
     "${Headers[@]}" \
     --output ${response})
#ds-snippet-end:Admin2Step3
#Step 3 End

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

CLM_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"product_id\"://' | sed 's/,".*//')
clm_profile_names=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/,/\n/g' | grep permission_profile_name | sed 's/.*\"permission_profile_name\":\"//g' | sed 's/\".*//g')
clm_profiles_count=$(echo "$clm_profile_names" | grep -c '^')

ESIGN_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"product_id\"://' | sed 's/,".*//')
esign_profile_names=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/,/\n/g' | grep permission_profile_name | sed 's/.*\"permission_profile_name\":\"//g' | sed 's/\".*//g')
esign_profiles_count=$(echo "$esign_profile_names" | grep -c '^')

if [ -z "$esign_profile_names" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "You must create an eSignature permission profile before running this code example"
    exit 1
elif [ "$esign_profiles_count" -eq "1" ]; then
    ESIGN_PERMISSION_PROFILE_ID=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $esign_profile_names | sed 's/.*\"ds_group_id\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select an eSignature permission profile to assign to the new user : '
    IFS=$'\n'
    select esign_permission_profile in $esign_profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$esign_profiles_count" ]; then
            ESIGN_PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"permission_profiles\"://' | sed 's/},/\n/g' | grep $esign_permission_profile | sed 's/.*\"permission_profile_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

if [ -z "$clm_profile_names" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "You must create a CLM permission profile before running this code example"
    exit 1
elif [ "$clm_profiles_count" -eq "1" ]; then
    CLM_PERMISSION_PROFILE_ID=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $clm_profile_names | sed 's/.*\"ds_group_id\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select a CLM permission profile to assign to the new user: '
    IFS=$'\n'
    select clm_permission_profile in $clm_profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$clm_profiles_count" ]; then
            CLM_PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"permission_profiles\"://' | sed 's/},/\n/g' | grep $clm_permission_profile | sed 's/.*\"permission_profile_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

echo ""
echo "Getting DS Groups..."
# Step 4 Start
#ds-snippet-start:Admin2Step4
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/dsgroups \
     "${Headers[@]}" \
     --output ${response})
#ds-snippet-end:Admin2Step4
#Step 4 End

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""
ds_group_names=$(cat $response | sed 's/,/\n/g' | grep group_name | sed 's/.*\"group_name\":\"//g' | sed 's/\".*//g')
groups_count=$(echo "$ds_group_names" | grep -c '^')

if [ -z "$ds_group_names" ]; then
    echo ""
    echo "Error:"
    echo ""
    echo "You must create a DS Group before running this code example"
    exit 1
elif [ "$groups_count" -eq "1" ]; then
    DS_GROUP_ID=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $ds_group_names | sed 's/.*\"ds_group_id\":\"//g' | sed 's/\".*//g')
else
    echo ""
    PS3='Select a DS Group to assign to the new user : '
    IFS=$'\n'
    select group_name in $ds_group_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$groups_count" ]; then
            DS_GROUP_ID=$(cat $response | sed 's/.*\"ds_groups\"://' | sed 's/},/\n/g' | grep $group_name | sed 's/.*\"ds_group_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi


# Create a temporary file to store the request data
request_data=$(mktemp /tmp/request-admin-001.XXXXXX)

read -p "Please enter a username for the new user: " USER_NAME
read -p "Please enter the first name for the new user: " FIRST_NAME
read -p "Please enter the last name for the new user: " LAST_NAME
read -p "Please enter an email for the new user: " EMAIL

#Step 5 start
#ds-snippet-start:Admin2Step5
printf \
'
{
    "user_name": "'${USER_NAME}'",
    "first_name": "'${FIRST_NAME}'",
    "last_name": "'${LAST_NAME}'",
    "email": "'${EMAIL}'",
    "auto_activate_memberships": true,
    "product_permission_profiles": [
        {
            "permission_profile_id": '$ESIGN_PERMISSION_PROFILE_ID',
            "product_id": '$ESIGN_PRODUCT_ID'
        },
        {
            "permission_profile_id": '$CLM_PERMISSION_PROFILE_ID',
            "product_id": '$CLM_PRODUCT_ID'
        }
    ],
    "ds_groups": [
        {
            "ds_group_id": "'$DS_GROUP_ID'"
        }
    ]
}' >$request_data
#ds-snippet-end:Admin2Step5
#Step 5 end

#Step 6 start
#ds-snippet-start:Admin2Step6
Status=$(
    curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/users/ \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}
)
#ds-snippet-end:Admin2Step6
#Step 6 end

# If the status code returned is greater than 201 (OK/Accepted), display an error message with the API response
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Failed to create a new user"
    echo ""
    cat $response
    exit 0
else
  # Store the email address into the config file for use in example 9
  echo $EMAIL >config/ESIGN_CLM_USER_EMAIL
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""
