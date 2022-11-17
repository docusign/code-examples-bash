#!/bin/bash
# Use embedded signing
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

source ./examples/eSignature/lib/utils.sh

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
# Step 2. Create the envelope.
#         The signer recipient includes a clientUserId setting
#
#  document 1 (pdf) has tag /sn1/
#  The envelope will be sent to the signer.

base_path="https://demo.docusign.net/restapi"

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-001-doc1.XXXXXX)

# Create a temporary file to store the response
echo ""
echo "Attempting to retrieve your account's workflow ID"
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)

# Step 2 start
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request GET ${base_path}/v2.1/accounts/${ACCOUNT_ID}/identity_verification \
     --output ${response}

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Unable to retrieve your account's workflow ID."
	echo ""
	cat $response
	exit 0
fi

# Retrieve the workflow IDs from the API response and put them in an array.
workflowIds=`cat $response | grep -o -P '(?<=workflowId\":\").*?(?=\")'`
arrWorkflowIds=($workflowIds)

# Get the index of the Phone auth workflow based on name and use that index for workflowId. 
# Workflow name of phone auth is 'Phone Authentication'
workflowNames=`cat $response | grep -o -P '(?<=defaultName\":).*?(?=,)'`
element="SMS for access & signatures"

workflowId=$(GetWorkflowId "$workflowNames" "$element" "$workflowIds")
# Step 2 end

if [ "$workflowId" == false ]; then
	echo ""
	echo "Please contact Support to enable recipient phone authentication in your account."
	echo ""
	exit 0
else
	echo ""
	echo "workflowId: " $workflowId
	echo ""
fi

# Get a country code and phone number for the signer
GetSignerPhoneNum

# Fetch doc and encode
cat $document_path | base64 > $doc1_base64

echo ""
echo "Sending the envelope request to DocuSign..."

# Step 3 start
# Concatenate the different parts of the request
printf \
'{
    "emailSubject": "Part 11 Example Consent Form",
	"emailBlurb": "Please let us know if you have any questions.",
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
                "clientUserId": "1000",
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "/sn1/",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20",
                            "anchorYOffset": "-30"
                        }
                    ]
                },
				"identityVerification":{
					"workflowId": "'"${workflowId}"'",
					"inputOptions": [{
						"name": "phone_number_list",
						"valueType": "PhoneNumberList",
						"phoneNumberList": [{
							"Number": "'"${SIGNER_PHONE_NUMBER}"'",
							"CountryCode": "'"${SIGNER_PHONE_COUNTRY}"'"
                    }]
                }]
            }
			}
        ]
    },
    "status": "sent"
}' >> $request_data
# Step 3 end
# Call DocuSign to create the envelope

# Step 4 start
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes \
     --output ${response}

echo ""
echo "Response:" `cat $response`
echo ""

# Pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
# Step 4 end
echo "EnvelopeId: ${envelope_id}"

# Create a recipient view (an embedded signing view)
#         that the signer will directly open in their browser to sign.
#
# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the
# query parameters passed back from DocuSign

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
# Step 5 start
printf \
'{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "'"${SIGNER_EMAIL}"'",
    "userName": "'"${SIGNER_NAME}"'",
    "clientUserId": 1000,
}' >> $request_data
# Step 5 end
# Create the recipient view and call the API to initiate the signing

echo ""
echo "Requesting the url for the embedded signing..."
echo ""
# Step 6 start
Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes/${envelope_id}/views/recipient \
     --output ${response})

if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Signing request failed."
	echo ""
	cat $response
	exit 0
fi

signing_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`
# ***DS.snippet.0.end
# Step 6 end
echo ""
echo "The embedded signing URL is ${signing_url}"
echo ""
echo "It is only valid for five minutes. Attempting to automatically open your browser..."

if which xdg-open &> /dev/null  ; then
  xdg-open "$signing_url"
elif which open &> /dev/null    ; then
  open "$signing_url"
elif which start &> /dev/null   ; then
  start "$signing_url"
fi

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo "Done."