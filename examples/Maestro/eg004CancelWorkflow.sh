#!/bin/bash
# Cancel a running workflow instance
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that there is a workflow
workflow_id=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_id" ]; then
    echo "Please run example 1 to create and trigger a worklow before running this example."
    exit 0
fi

# Check that there is a running workflow instance to cancel
WORKFLOW_INSTANCE_ID=$(cat config/INSTANCE_ID)
if [ -z "$WORKFLOW_INSTANCE_ID" ]; then
    echo "Please run example 1 to trigger a workflow before running this example."
    exit 0
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)


# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)

base_path="https://api-d.docusign.com/v1"

# Construct your API headers
#ds-snippet-start:Maestro4Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Maestro4Step2
echo ""
echo "Attempting to cancel the Workflow instance..."
echo ""

#ds-snippet-start:Maestro4Step3
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(
    curl -w '%{http_code}' --request POST "${base_path}/accounts/${ACCOUNT_ID}/workflows/${workflow_id}/instances/${WORKFLOW_INSTANCE_ID}/actions/cancel" \
    "${Headers[@]}" \
    --output ${response}
)
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve workflow instance: ${WORKFLOW_INSTANCE_ID}"
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Workflow has been canceled."
echo ""
echo ""
echo "Response:"
cat $response
echo ""
echo ""
#ds-snippet-end:Maestro4Step3

# Remove the temporary files
rm "$response"