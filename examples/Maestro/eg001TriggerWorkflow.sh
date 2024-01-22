#!/bin/bash
# https://developers.docusign.com/docs/workflows-api/trigger-workflow
# Trigger a new instance of a workflow
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

workflow_id=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_id" ]; then
    bash ./examples/Maestro/utils.sh
fi

#check that create workflow script ran successfully
workflow_id=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_id" ]; then
    echo "please create a worklow before running this example"
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
#ds-snippet-start:Maestro1Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Maestro1Step2

echo ""
echo "Attempting to retrieve Workflow definition"
echo ""
#ds-snippet-start:Maestro1Step3
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(
    curl -w '%{http_code}' -i --request GET "${base_path}/management/accounts/${account_id}/workflowDefinitions/${workflow_id}" \
    "${Headers[@]}" \
    --output ${response}
)
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve workflow definition with workflow ID: ${workflow_id}"
    echo ""
    cat $response
    exit 0
fi

trigger_url=`cat $response | grep triggerUrl | sed 's/.*\"triggerUrl\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:Maestro1Step3

echo "Please input a name for the workflow instance: "
read instance_name

echo "Please input the full name for the signer participant: "
read signer_name

echo "Please input an email for the signer participant: "
read signer_email

echo "Please input the full name for the cc participant: "
read cc_name

echo "Please input an email for the cc participant: "
read cc_email

#ds-snippet-start:Maestro1Step4
request_data=$(mktemp /tmp/request-wf-001.XXXXXX)
printf \
'{
  "instanceName": "'"$instance_name"'",
  "participants": {},
  "payload": {
    "signerEmail": "'"${signer_email}"'",
    "signerName": "'"${signer_name}"'",
    "ccEmail": "'"${cc_email}"'",
    "ccName": "'"${cc_name}"'"
  },
  "metadata": {}
}' >$request_data
#ds-snippet-end:Maestro1Step4

#ds-snippet-start:Maestro1Step5
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" --request POST ${trigger_url} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Maestro1Step5

# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to trigger a new instance of the specified workflow ${workflow_id}"
    echo ""
    cat $response
    exit 0
fi

instance_id=`cat $response | grep instanceId | sed 's/.*\"instanceId\":\"//' | sed 's/\".*//'`
# Store the instance_id into the config file
echo $instance_id >config/INSTANCE_ID

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"