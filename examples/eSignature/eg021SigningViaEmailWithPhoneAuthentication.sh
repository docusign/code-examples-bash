# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)

#Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct your envelope JSON body
# Create a temporary file to store the JSON body

doc_base64=$(mktemp /tmp/eg-019-doc1.XXXXXX)
cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc_base64


read -p "Please enter a phone number for recipient authentication [415-555-1212]: " PHONE
PHONE=${PHONE:-"415-555-1212"}


request_data=$(mktemp /tmp/request-cw.XXXXXX)
printf \
'{
	"documents": [{
		"documentBase64": "'"${doc_base64}"'",
		"documentId": "1",
		"fileExtension": "pdf",
		"name": "Lorem"
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
			"routingOrder": 2,
			"status": "created",
			"tabs": {
				"signHereTabs": [{
					"documentId": "1",
					"name": "SignHereTab",
					"pageNumber": "1",
					"recipientId": "1", #This value represents your {RECIPIENT_ID}
					"tabLabel": "SignHereTab",
					"xPosition": "75",
					"yPosition": "572"
				}]
			},
			"templateAccessCodeRequired": null,
			"deliveryMethod": "email",
			"recipientId": "1", #This value represents your {RECIPIENT_ID}
			"accessCode": "",
			"phoneAuthentication": {
				"recordVoicePrint": false,
				"validateRecipProvidedNumber": false,
				"recipMayProvideNumber": true,
				"senderProvidedNumbers": ["'"${PHONE}"'"]
			},
			"smsAuthentication": null,
			"idCheckConfigurationName": "Phone Auth $",
			"requireIdLookup": true
			}]
		},
	"status": "Sent"
}
' >> $request_data
									
# Step 4: a) Make a POST call to the createEnvelopes endpoint to create a new envelope.
#         b) Display the JSON structure of the created envelope
echo ""
echo "Request:"
echo ""
cat $request_data
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
curl --request POST "https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes" \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response}

echo ""
echo "Response:"
cat $response
# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo ""
echo "Done."
echo ""

