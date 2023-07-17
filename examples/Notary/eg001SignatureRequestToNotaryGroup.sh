# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)
ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)
base_path="https://demo.docusign.net/restapi"

# Send an envelope
# Get required environment variables from .\config\settings.json file
if [[ $NOTARY_EMAIL == "" || NOTARY_NAME == "" || NOTARY_API_ACCOUNT_ID == "" ]] ; then
  echo "NOTARY_EMAIL, NOTARY_NAME, and NOTARY_API_ACCOUNT_ID are needed. Please add the NOTARY_EMAIL, NOTARY_NAME, and NOTARY_API_ACCOUNT_ID variables to the settings.txt"
  exit 1
fi

#ds-snippet-start:Notary1Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
doc_base64=$(mktemp /tmp/eg-001-doc.XXXXXX)

cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc_base64

echo "Sending the envelope request to DocuSign..."
echo "The envelope processing time will be about 15 seconds."
echo "Response:"

# Concatenate the different parts of the request

#ds-snippet-start:Notary1Step3
printf \
'{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "documentBase64": "' >> $request_data
                cat $doc_base64 >> $request_data
                printf '",
            "name": "Order acknowledgement",
            "fileExtension": "html",
            "documentId": "1",
        },
    ],
    "recipients": {
        "notaries": [
            {
                "email": "'"$NOTARY_EMAIL"'",
                "name": "'"$NOTARY_NAME"'",
                "recipientId": "1",
                "routingOrder": "1",
                "tabs": {
                    "notarySealTabs": [
                        {
                            "xPosition": "300",
                            "yPosition": "235",
                            "documentId": "1",
                            "pageNumber": "1",
                        },
                    ],
                    "signHereTabs": [
                        {
                            "xPosition": "300",
                            "yPosition": "150",
                            "documentId": "1",
                            "pageNumber": "1",
                        },
                    ]
                },
                "userId": "'"$NOTARY_API_ACCOUNT_ID"'",
                "notaryType": "remote",
            },
        ],
        "signers": [
            {
                "clientUserId": "12345",
                "email": "'"$SIGNER_EMAIL"'",
                "name": "'"$SIGNER_NAME"'",
                "recipientId": "2",
                "routingOrder": "1",
                "notaryId": "1",
                "tabs": {
                    "signHereTabs": [
                        {
                            "documentId": "1",
                            "xPosition": "200",
                            "yPosition": "235",
                            "pageNumber": "1",
                        },
                        {
                            "stampType": "stamp",
                            "documentId": "1",
                            "xPosition": "200",
                            "yPosition": "150",
                            "pageNumber": "1",
                        },
                    ],
                },
            },
        ],
    },
    "status": "sent"
}' >> $request_data
#ds-snippet-end

# Create and send the envelope
#ds-snippet-start:Notary1Step4
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response

echo "Response: "
cat $response
#ds-snippet-end
# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

# Save the envelope id for use by other scripts
echo "EnvelopeId: ${envelope_id}"
echo ${envelope_id} > config/ENVELOPE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc_base64"

echo ""
echo ""
echo "Done."
echo ""
