#!/bin/bash
# Shared access
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

source launcher.sh

ds_access_token_path="config/ds_access_token.txt"
api_account_id_path="config/API_ACCOUNT_ID"
document_path="demo_documents/World_Wide_Corp_lorem.pdf"

if [ ! -f $ds_access_token_path ]; then
    ds_access_token_path="../config/ds_access_token.txt"
    api_account_id_path="../config/API_ACCOUNT_ID"
    document_path="../demo_documents/World_Wide_Corp_lorem.pdf"
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat ${api_account_id_path})

# ***DS.snippet.0.start

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# temp files:
request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-042-doc1.XXXXXX)

echo "Please enter the name of the new user: "
read AGENT_NAME
echo "Please enter an email address for the new user: "
read AGENT_EMAIL
echo "Please input an activation code for the new user. Save this code. You'll need it when activating the new user."
read ACTIVATION

# Create a second user in the account
printf \
'{
  "newUsers": [
    {
      "activationAccessCode": "'"${ACTIVATION}"'",
      "userName": "'"${AGENT_NAME}"'",
      "email": "'"${AGENT_EMAIL}"'"
    }
  ]
}' >> $request_data

Status=$(curl --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})

echo ""
echo "Response: "
cat $response
echo ""

AGENT_USER_ID=`cat $response | grep userId | sed 's/.*\"userId\":\"//' | sed 's/\",.*//'`

echo "" 
echo "Agent user has been created. Please activate user and press 1 to continue the example: "
read choice

if [ "$choice" != "1" ]; then 
echo "Closing the example... "
exit 0

else
rm "$request_data"
rm "$response"

# Sharing the envelope with user

request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)

# Construct the request body
printf \
'{
    "agentUser":
        {
            "userId": "'"${AGENT_USER_ID}"'",
            "accountId": "'"${ACCOUNT_ID}"'"
        },
    "permission": "manage"
}' >> $request_data

Status=$(curl --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/users/${IMPERSONATION_USER_GUID}/authorization \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})

rm "$request_data"
rm "$response"

# Creating the envelope

# Fetch doc and encode
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64


echo "Sending the envelope request to DocuSign..."
echo "Results:"
echo ""

request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)
create_envelope="examples/eSignature/eg002SigningViaEmail.sh"

# Concatenate the different parts of the request
printf \
'{
    "emailSubject": "Please sign this document",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
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

Status=$(curl --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})

echo ""
echo "Response:"
cat $response
echo ""

envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

# User 2 checks the envelope status
echo "Your envelope ID is: ${envelope_id}"
echo ""
echo "Close the launcher and activate the second user on developers.docusign.com."
echo "Restart the launcher and authenticate as the second user."
echo "Run example 4 - get envelope info and verify your envelope ID is in the list."

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo "Done."

fi