#!/bin/bash
# Send an Workspace Envelope with Recipient Info
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that a workspace exists
workspace_id=$(cat config/WORKSPACE_ID)
if [ -z "$workspace_id" ]; then
    echo "Please create a workspace before running this example"
    exit 0
fi

# Check that a workspace creator ID exists
workspace_creator_id=$(cat config/WORKSPACE_CREATOR_ID)
if [ -z "$workspace_creator_id" ]; then
    echo "No creator ID was recorded. Please create a workspace before running this example"
    exit 0
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

# Calculate ISO 8601 date 7 days from now
# Uses 'date -v +7d' on macOS or 'date -d "+7 days"' on Linux (GNU date)
if date -v +1d > /dev/null 2>&1; then
    # macOS/BSD 'date'
    DUE_DATE=$(date -v +7d "+%Y-%m-%dT%H:%M:%SZ")
else
    # Linux (GNU 'date')
    DUE_DATE=$(date -d "+7 days" "+%Y-%m-%dT%H:%M:%SZ")
fi

# This header will be used for both the API call to get the ID of the workspace creator, and to create the upload request
#ds-snippet-start:Workspaces4Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Workspaces4Step2

# Create the workspace upload request definition
#apx-snippet-start:createWorkspaceUploadRequest
#ds-snippet-start:Workspaces4Step3
printf \
'{
    "name": "Upload Request example '"${DUE_DATE}"'",
    "description": "This is an example upload request created via the workspaces API",
    "due_date": "'"${DUE_DATE}"'",
    "assignments": [
        {
            "upload_request_responsibility_type_id": "assignee",
            "first_name": "Test",
            "last_name": "User",
            "email": "'"${SIGNER_EMAIL}"'"
        },
        {
            "assignee_user_id": "'"${workspace_creator_id}"'",
            "upload_request_responsibility_type_id": "watcher"
        }
    ],
    "status": "draft"
}' >> $request_data
#ds-snippet-end:Workspaces4Step3

#ds-snippet-start:Workspaces4Step4
Status=$(curl -s -w "%{http_code}\n" -i \
     --request POST ${base_path}/accounts/${account_id}/workspaces/${workspace_id}/upload-requests \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Workspaces4Step4
#apx-snippet-end:createWorkspaceUploadRequest

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to create Workspace upload request."
	echo ""
    cat $Status
	cat $response
	exit 0
fi

echo ""
echo "Response:" 
cat $response
echo ""

# Get the workspace upload request ID and display it
upload_request_id=`cat $response | grep upload_request_id | sed 's/.*\"upload_request_id\":\"//' | sed 's/".*//'`
echo "Workspace upload request created! ID: ${upload_request_id}"

rm "$response"
rm "$request_data"


