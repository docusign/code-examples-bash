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

base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Obtain your workflow ID
# Create a temporary file to store
request_data=$(mktemp /tmp/request-idv.XXXXXX)

# Create a temporary file to store the response
echo ""
echo "Attempting to retrieve your account's workflow ID"
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/identity_verification" \
     "${Headers[@]}" \
     --output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Unable to retrieve your account's workflow ID."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Retrieve the default workflow ID from the API response. It will be the first workflow ID in the returned JSON.
workflowIds=`cat $response | grep -o -P '(?<=workflowId\":\").*?(?=\")'`
arrWorkflowIds=($workflowIds)
workflowId=${arrWorkflowIds[0]}

# Remove the temporary files
rm "$request_data"
rm "$response"

# Step 4: Construct the JSON body for your envelope
# Note: If you did not successfully obtain your workflow ID, step 4 will fail.
doc_base64=$(mktemp /tmp/base64doc-idv.XXXXXX)
cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc_base64
request_data=$(mktemp /tmp/request-idv.XXXXXX)

printf \
'{
	"documents": [{
		 "documentBase64": "' > $request_data
            cat $doc_base64 >> $request_data
            printf '",
		"documentId": "1",
		"fileExtension": "txt",
		"name": "NDA"
	}],
	"emailBlurb": "Sample text for email body",
	"emailSubject": "Please Sign",
	"envelopeIdStamping": "true",
	"recipients": {
	"signers": [{
		"name": "'"${SIGNER_NAME}"'",
		"email": "'"${SIGNER_EMAIL}"'",
		"roleName": "",
		"note": "",
		"routingOrder": 1,
		"status": "created",
"tabs": {
				"signHereTabs": [{
					"documentId": "1",
					"name": "SignHereTab",
					"pageNumber": "1",
					"recipientId": "1", 
					"tabLabel": "SignHereTab",
					"xPosition": "0",
					"yPosition": "1"
				}]
			},
		"templateAccessCodeRequired": null,
		"deliveryMethod": "email",
		"recipientId": "1",
		"identityVerification": {
			"workflowId": "'"${workflowId}"'",
			"steps": null
		},
		"idCheckConfigurationName": "",
		"requireIdLookup": false
	}]
	},
	"status": "Sent"
}
' >> $request_data
					
# Step 5: a) Make a POST call to the createEnvelopes endpoint to create a new envelope.
#         b) Display the JSON structure of the created envelope
# Create a temporary file to store the response
response=$(mktemp /tmp/response-idv.XXXXXX)
curl --request POST "https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes" \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response}


echo ""
echo "Response:"
cat $response
echo ""
# Remove the temporary files
rm "$request_data"
rm "$response"
echo ""
echo ""
echo "Done."
echo ""
