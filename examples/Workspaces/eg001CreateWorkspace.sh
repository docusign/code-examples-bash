#!/bin/bash
# Create a workspace
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

#Set the Workspace API base path
base_path="https://api-d.docusign.com/v1"

request_data=$(mktemp /tmp/request-wseg-001.XXXXXX)
response=$(mktemp /tmp/response-wseg-001.XXXXXX)

#ds-snippet-start:Workspaces1Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Workspaces1Step2

# Create the workspace definition
#apx-snippet-start:createWorkspace
#ds-snippet-start:Workspaces1Step3
printf \
'{
    "name" : "Example workspace"
}' >> $request_data
#ds-snippet-end:Workspaces1Step3

#ds-snippet-start:Workspaces1Step4
Status=$(curl -s -w "%{http_code}\n" -i \
     --request POST ${base_path}/accounts/${account_id}/workspaces \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Workspaces1Step4
#apx-snippet-end:createWorkspace

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to create Workspace."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:" 
cat $response
echo ""

# Pull out the workspace ID and save it
workspace_id=`cat $response | grep workspace_id | sed 's/.*\"workspace_id\":\"//' | sed 's/".*//'`
workspace_creator_id=$(grep -o -m 1 '"created_by_user_id":"[^"]*"' "$response" | \
                           sed 's/.*"created_by_user_id":"\([^"]*\)".*/\1/')
echo "Workspace created by user ${workspace_creator_id}!  Workspace ID: ${workspace_id}"
echo ${workspace_id} > config/WORKSPACE_ID
echo ${workspace_creator_id} > config/WORKSPACE_CREATOR_ID

rm "$response"
rm "$request_data"
