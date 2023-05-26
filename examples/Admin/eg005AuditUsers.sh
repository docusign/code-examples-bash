#!/bin/bash
# Audit users with the Admin API
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that ORGANIZATION_ID has been set
ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)
if [[ -z "$ORGANIZATION_ID" ]]; then
    echo "PROBLEM: Set ORGANIZATION_ID and add to config directory"
fi


# Note: Substitute these values with your own
# Obtain your OAuth token
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

# Construct your API headers
# Step 2 start
#ds-snippet-start:Admin5Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin5Step2
# Step 2 end

# Step 3 start
#ds-snippet-start:Admin5Step3
# Calculate date parameter to get users modified in the last 10 days
if date -v -10d &>/dev/null; then
    # Mac
    # modified_since=`date -v -10d '+%Y-%m-%dT%H:%M:%S%z'`
    modified_since=$(date -v -10d '+%Y-%m-%d')
else
    # Not a Mac
    # modified_since=`date --date='-10 days' '+%Y-%m-%dT%H:%M:%S%z'`
    modified_since=$(date --date='-10 days' '+%Y-%m-%d')
fi

response=$(mktemp /tmp/response-admin.XXXXXX)

# Call the Admin API
Status=$(
    curl -w '%{http_code}' --request GET "${base_path}/v2/organizations/${ORGANIZATION_ID}/users?account_id=${API_ACCOUNT_ID}&last_modified_since${modified_since}" \
    "${Headers[@]}" \
    --output $response
)
#ds-snippet-end:Admin5Step3
# Step 3 end

# Step 4 start
#ds-snippet-start:Admin5Step4
modified_users=$(cat $response)
user_emails=`echo $modified_users | grep -o -P '(?<=email\":\").*?(?=\")'`
array_emails=($user_emails)
#ds-snippet-end:Admin5Step4
# Step 4 end

# Step 5 start
#ds-snippet-start:Admin5Step5
profiles=$(mktemp /tmp/profiles-oa.XXXXXX)

echo ''
echo 'User profiles:'

for email in ${array_emails[@]}
do

    Status=$(
        curl -w '%{http_code}' -i --request GET "${base_path}/v2/organizations/${ORGANIZATION_ID}/users/profile?email=${email}" \
        "${Headers[@]}" \
        --output ${profiles}
    )

    echo ''
    cat $profiles
    echo ''

done
#ds-snippet-end:Admin5Step5
# Step 5 end

# Remove the temporary files"
rm "$profiles"
rm "$response"

echo ""
echo "Done."
echo ""
