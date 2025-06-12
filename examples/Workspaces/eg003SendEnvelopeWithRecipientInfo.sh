#!/bin/bash
# Send an Workspace Envelope with Recipient Info
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

#check that a workspace exists
workspace_id=$(cat config/WORKSPACE_ID)
if [ -z "$workspace_id" ]; then
    echo "please create a workspace before running this example"
    exit 0
fi

#check that a document exists in the workspace
document_id=$(cat config/DOCUMENT_ID)
if [ -z "$workspace_id" ]; then
    echo "please create a document in the workspace before running this example"
    exit 0
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)


# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

#Set the Workspace API base path
workspaces_base_path="https://api-d.docusign.com/v1"

request_data=$(mktemp /tmp/request-wseg-001.XXXXXX)
response=$(mktemp /tmp/response-wseg-001.XXXXXX)

#ds-snippet-start:Workspaces3Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Workspaces3Step2

# Create the workspace envelope definition
#ds-snippet-start:Workspaces3Step3
printf \
'{
    "envelope_name": "Example Workspace Envelope", 
    "document_ids": ["'"${document_id}"'"]
}' >> $request_data
#ds-snippet-end:Workspaces3Step3

#ds-snippet-start:Workspaces3Step4
Status=$(curl -s -w "%{http_code}\n" -i \
     --request POST ${workspaces_base_path}/accounts/${account_id}/workspaces/${workspace_id}/envelopes \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:Workspaces3Step4

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to send envelope."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:" 
cat $response
echo ""

# pull out the envelope_id
envelope_id=`cat $response | grep envelope_id | sed 's/.*\"envelope_id\":\"//' | sed 's/".*//'`
echo "Envelope created! ID: ${envelope_id}"

rm "$response"
rm "$request_data"
request_data=$(mktemp /tmp/request2-wseg-001.XXXXXX)
response=$(mktemp /tmp/response2-wseg-001.XXXXXX)

#Set the eSignature REST API base path
esign_base_path="https://demo.docusign.net/restapi"

#ds-snippet-start:Workspaces3Step5
printf \
'{
    "emailSubject": "Please sign this document",
    "recipients": {
        "signers": [
            {
                "email": "'"${SIGNER_EMAIL}"'",
                "name": "'"${SIGNER_NAME}"'",
                "recipientId": "1",
                "routingOrder": "1",
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "/sn1/",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        }
                    ]
                }
            }
        ]
    },
    "status": "sent"
}' >> $request_data
#ds-snippet-end:Workspaces3Step5

#ds-snippet-start:Workspaces3Step6
Status=$(curl -s -o "${response}" -w "%{http_code}" \
  --request PUT "${esign_base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}" \
  "${Headers[@]}" \
  --data-binary @"${request_data}")
#ds-snippet-end:Workspaces3Step6

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to send envelope."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:" 
cat $response
echo ""
echo ""
echo "Envelope Sent!"
echo ""

rm "$response"
rm "$request_data"