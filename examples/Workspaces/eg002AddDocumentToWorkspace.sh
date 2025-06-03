#!/bin/bash
# https://developers.docusign.com/docs/workspaces-api
# Add a document to a Workspace
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

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

# Set the Workspace API base path
base_path="https://api-d.docusign.com/v1"


response=$(mktemp /tmp/response-wseg-002.XXXXXX)

#ds-snippet-start:Workflows2Step2
declare -a Headers=(
    --header "Authorization: Bearer ${ACCESS_TOKEN}"
    --header "Accept: application/json"
)
#ds-snippet-end:Workflows2Step2


# Upload the file path to be added to the workspace 
#ds-snippet-start:Workflows2Step3
echo ""
echo "Enter the path to the document you want to add to the workspace:"
echo ""
read file_path

if [ ! -f "$file_path" ]; then
    echo "File does not exist: $file_path"
    exit 1
fi

# Enter the document name for the workspace
echo ""
echo "Enter the name for the document in the workspace:"
echo ""

read doc_name
#ds-snippet-end:Workflows2Step3

#ds-snippet-start:Workflows2Step4
Status=$(curl -s -w "%{http_code}" -o "${response}" \
    --request POST "${base_path}/accounts/${account_id}/workspaces/${workspace_id}/documents" \
    "${Headers[@]}" \
    -F "file=@${file_path}" \
    -F "name=${doc_name}"
)
#ds-snippet-end:Workflows2Step4


if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Failed to add document to workspace."
    echo ""
    cat $response
    rm "$response"
    exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Pull out the document ID and save it
document_id=$(cat $response | grep document_id | sed 's/.*"document_id":"//' | sed 's/".*//')
echo "Document added! ID: ${document_id}"
echo ${document_id} > config/DOCUMENT_ID

rm "$response"