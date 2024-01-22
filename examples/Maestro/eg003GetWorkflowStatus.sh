#!/bin/bash
# https://developers.docusign.com/docs/workflows-api/trigger-workflow
# Get the status of an instance of a workflow
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

#check that create workflow script ran successfully
workflow_id=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_id" ]; then
    echo "please create a worklow before running this example"
    exit 0
fi

workflow_instance_id=$(cat config/INSTANCE_ID)
if [ -z "$workflow_instance_id" ]; then
    echo "please trigger a workflow before running this example"
    exit 0
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)


# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.services.docusign.net/aow-manage/v1.0"

# Construct your API headers
#ds-snippet-start:Maestro3Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Maestro3Step2
echo ""
echo "Attempting to retrieve Workflow Instance Status"
echo ""

#ds-snippet-start:Maestro3Step3
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(
    curl -w '%{http_code}' --request GET "${base_path}/management/accounts/${account_id}/workflowDefinitions/${workflow_id}/instances/${workflow_instance_id}" \
    "${Headers[@]}" \
    --output ${response}
)
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve workflow instance: ${workflow_instance_id}"
    echo ""
    cat $response
    exit 0
fi

status=`cat $response | grep instanceState | sed 's/.*\"instanceState\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:Maestro3Step3

echo ""
echo "Full Response Output:"
cat $response
echo ""
echo ""
echo "Workflow Status:"
echo $status
echo ""

# Remove the temporary files
rm "$response"
