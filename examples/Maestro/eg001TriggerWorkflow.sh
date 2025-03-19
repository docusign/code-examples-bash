#!/bin/bash
# https://developers.docusign.com/docs/workflows-api/trigger-workflow
# Trigger a new instance of a workflow
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

workflow_created=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_created" ]; then
    bash ./examples/Maestro/utils.sh
fi

#check that create workflow script ran successfully
workflow_created=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_created" ]; then
    echo "please create a worklow before running this example"
    exit 0
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)


# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://api-d.docusign.com/v1"

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
#apx-snippet-start:GetWorkflowsList
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(
    curl -w '%{http_code}' --request GET "${base_path}/accounts/${account_id}/workflows" \
    "${Headers[@]}" \
    --output ${response}
)
#apx-snippet-end:GetWorkflowsList
# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to retrieve a workflow definition"
    echo ""
    cat $response
    exit 0
fi

echo "Response:"
cat $response
echo ""

workflow_id=$(grep -B 1 '"name": "Example workflow - send invite to signer"' $response | grep '"id":' | sed -n 's/.*"id": "\([^"]*\)".*/\1/p')

# Get the trigger URL
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" -i --request GET "${base_path}/accounts/${account_id}/workflows/${workflow_id}/trigger-requirements" \
    "${Headers[@]}" \
    --output ${response})

# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to trigger a new instance of the specified workflow ${workflow_id}"
    echo ""
    cat $response
    exit 0
fi

echo "Response:"
cat $response
echo ""

trigger_url=$(grep '"url":' $response | sed -n 's/.*"url": "\([^"]*\)".*/\1/p')
decoded_trigger_url=$(echo $trigger_url | sed 's/\\u0026/\&/g')
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
  "instance_name": "'"$instance_name"'",
  "trigger_inputs": {
    "signerEmail": "'"${signer_email}"'",
    "signerName": "'"${signer_name}"'",
    "ccEmail": "'"${cc_email}"'",
    "ccName": "'"${cc_name}"'"
  }
}' >$request_data
#ds-snippet-end:Maestro1Step4

#ds-snippet-start:Maestro1Step5
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" -i --request POST ${decoded_trigger_url} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Maestro1Step5


instance_id=`cat $response | grep instance_id | sed 's/.*\"instance_id\":\"//' | sed 's/\".*//'`
# Store the instance_id into the config file
echo $instance_id >config/INSTANCE_ID

echo ""
echo "Response:"
cat $response
echo ""

instance_url=$(grep '"instance_url":' $response | sed -n 's/.*"instance_url": "\([^"]*\)".*/\1/p')
decoded_instance_url=$(echo $instance_url | sed 's/\\u0026/\&/g')
echo ""
echo "Use this URL to complete the workflow steps:"
echo $decoded_instance_url

# Remove the temporary files
rm "$request_data"
rm "$response"