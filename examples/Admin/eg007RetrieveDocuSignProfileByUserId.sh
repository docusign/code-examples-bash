#!/bin/bash
# Retreives DocuSign Profile for a user given the user's email address with the Admin API
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
ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

echo "Please input userId to lookup DocuSign profile:"
read USER_ID

# Construct your API headers
# Step 2 start
#ds-snippet-start:Admin7Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin7Step2
# Step 2 end

# Step 3 start
#ds-snippet-start:Admin7Step3
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
curl --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/users/${USER_ID}/dsprofile \
    "${Headers[@]}" \
    --output ${response}

#ds-snippet-end:Admin7Step3
# Step 3 end

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary file
rm "$response"
