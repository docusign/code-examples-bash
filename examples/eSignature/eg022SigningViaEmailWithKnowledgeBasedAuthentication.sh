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

# Step 2: Construct your API headers
#ds-snippet-start:eSign22Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

#ds-snippet-end:eSign22Step2
# Step 3: Construct your envelope JSON body
# Create a temporary file to store the JSON body
is_data_correct=true
while $is_data_correct; do
	read -p "Please enter name for the signer: " RECIPIENT_NAME
	read -p "Please enter email address for the signer: " RECIPIENT_EMAIL

	if [[ "$RECIPIENT_EMAIL" = "$SIGNER_EMAIL" ]]; then
	  echo ""
		echo "For recipient authentication you must specify a different recipient from the account owner (sender) in order to ensure recipient authentication is performed"
		echo ""
	else
		is_data_correct=false
	fi
done

doc_base64=$(mktemp /tmp/eg-019-doc1.XXXXXX)
cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc_base64

request_data=$(mktemp /tmp/request-cw.XXXXXX)
#ds-snippet-start:eSign22Step3
printf \
'{
	"documents": [{
		"documentBase64":"' > $request_data
            cat $doc_base64 >> $request_data
            printf '",
		"documentId": "1",
		"fileExtension": "docx",
		"name": "Lorem"
	}],
	"emailBlurb": "Sample text for email body",
	"emailSubject": "Please Sign",
	"envelopeIdStamping": "true",
	"recipients": {
		"signers": [{
			"deliveryMethod": "Email",
			"name": "'"${RECIPIENT_NAME}"'",
			"email": "'"${RECIPIENT_EMAIL}"'",
			"idCheckConfigurationName": "ID Check",
			"recipientId": "1",
			"requireIdLookup": "true",
			"routingOrder": "1",
			"status": "Created",
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
			}
		}]
	},
	"status": "Sent"
}' >> $request_data				
#ds-snippet-end:eSign22Step3
					
# Step 4: a) Make a POST call to the createEnvelopes endpoint to create a new envelope.
#         b) Display the JSON structure of the created envelope
echo ""
echo "Request:"
echo ""
cat $request_data
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
#ds-snippet-start:eSign22Step4
curl --request POST "https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes" \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response}
#ds-snippet-end:eSign22Step4

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

