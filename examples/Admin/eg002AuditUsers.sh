#!/bin/bash
# Audit users with the Admin API
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

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
# Step 2 end

# Step 3 start
Status=$(
    curl -w '%{http_code}' --request GET "${base_path}/v2/organizations/${ORGANIZATION_ID}/users?account_id=${API_ACCOUNT_ID}&last_modified_since=2020-05-01" \
    "${Headers[@]}" \
    --output modified.txt
)
# Step 3 end

# Step 4 start
modified_users=$( cat modified.txt | jq -r '.users[].email')
# Step 4 end

# Step 5 start
profiles=$(mktemp /tmp/profiles-oa.XXXXXX)

echo ''
echo 'User profiles:'

for user in $modified_users
do

    Status=$(
        curl -w '%{http_code}' -i --request GET "${base_path}/v2/organizations/${ORGANIZATION_ID}/users/profile?email=${user}" \
        "${Headers[@]}" \
        --output ${profiles}
    )

    echo ''
    cat $profiles
    echo ''

done

# Remove the temporary files"
rm "$profiles"
# Step 5 end


echo ""
echo "Done."
echo ""