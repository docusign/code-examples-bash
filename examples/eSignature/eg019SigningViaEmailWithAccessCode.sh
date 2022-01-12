# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

#Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")
# Step 2 end
 
doc1_base64=$(mktemp /tmp/eg-002-doc1.XXXXXX)
doc2_base64=$(mktemp /tmp/eg-002-doc2.XXXXXX)
doc3_base64=$(mktemp /tmp/eg-002-doc3.XXXXXX)

# Fetch docs and encode
cat demo_documents/doc_1.html | base64 > $doc1_base64
cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc2_base64
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc3_base64

read -p "Please enter signer email address: (Note: must use a different email from the one used to create the developer account)" SIGNER_EMAIL
read -p "Please enter signer name: " SIGNER_NAME

read -p "Please enter a an access code for recipient authentication [nj91@c]: " ACCESS_CODE
ACCESS_CODE=${ACCESS_CODE:-"nj91@c"}
request_data=$(mktemp /tmp/request-ds.XXXXXX)

# Create a temporary file to store the JSON body
# Step 3 start
printf \
'{
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Order acknowledgement",
            "fileExtension": "html",
            "documentId": "1"
        },
        {
            "documentBase64": "' >> $request_data
            cat $doc2_base64 >> $request_data
            printf '",
            "name": "Battle Plan",
            "fileExtension": "docx",
            "documentId": "2"
        },
        {
            "documentBase64": "' >> $request_data
            cat $doc3_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "3"
        }
    ],
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
					"xPosition": "75",
					"yPosition": "572"
				}]
			},
		"templateAccessCodeRequired": null,
		"deliveryMethod": "email",
		"recipientId": "1",
		"accessCode": "'"${ACCESS_CODE}"'",
		"smsAuthentication": null,
		"idCheckConfigurationName": "",
		"requireIdLookup": false
	}]
	},
	"status": "Sent"
}
' >> $request_data
#Step 3 end

echo "Access code for this example is ${ACCESS_CODE}"
echo ""
# Step 4: a) Make a POST call to the createEnvelopes endpoint to create a new envelope.
#         b) Display the JSON structure of the created envelope
echo ""
echo "Request:"
echo ""
cat $request_data
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
# Step 4 start
curl --request POST "https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes" \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response}
# Step 4 end

echo ""
echo "Response:"
cat $response
echo ""
# Remove the temporary files
rm "$request_data"
rm "$response"