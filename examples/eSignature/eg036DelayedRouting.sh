# Send an envelope with three documents
#
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

# ***DS.snippet.0.start
#  document 1 (pdf) has tag /sn1/
#
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - signer
#  The envelope will be sent first to the signer.
#  There will be a one day delay before it is sent to the second signer.

# temp files:
request_data=$(mktemp /tmp/request-eg-002.XXXXXX)
response=$(mktemp /tmp/response-eg-002.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-002-doc1.XXXXXX)

# Fetch docs and encode
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64

# Get the email and name for the second signer
read -p "Enter an email address for the second signer recipient different from the first signer: " SIGNER_EMAIL2
read -p "Enter a name for the second signer recipient: " SIGNER_NAME2

read -p "Please enter the delay (in hours): " DELAY_HOURS

DELAY_DAYS="0."
DELAY_MINUTES_SECONDS="00:00"
DELAY="$DELAY_DAYS$DELAY_HOURS:$DELAY_MINUTES_SECONDS"

echo ""
echo "Sending the envelope request to DocuSign..."
echo "The envelope has three documents. Processing time will be about 15 seconds."
echo "Results:"
echo ""

# Concatenate the different parts of the request
# Step 2 start
printf \
'{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "documentBase64": "' >> $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
    "workflow": {
        "workflowSteps": [{
            "action": "pause_before",
            "triggerOnItem": "routing_order",
            "itemId": 2,
            "status": "pending",
            "delayedRouting": {
                "rules": [{
                    "delay": "'"${DELAY}"'"
                }]
            }
        }]
    },
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
            },
            {
                "email":  "'"${SIGNER_EMAIL2}"'",
                "name": "'"${SIGNER_NAME2}"'",
                "recipientId": "2",
                "routingOrder": "2",
                "tabs": {
                    "signHereTabs": [
                        {
                            "xPosition": "400",
                            "yPosition": "172",
                            "documentId": "1",
                            "pageNumber": "1"
                        }
                    ]
                }

            }
        ]
    },
    "status": "sent"
}' >> $request_data
# Step 2 end

# Step 3 start
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response
# Step 3 end

echo ""
echo "Response:"
cat $response
echo ""

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
# ***DS.snippet.0.end
# Save the envelope id for use by other scripts
echo "EnvelopeId: ${envelope_id}"
echo ${envelope_id} > config/ENVELOPE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""
