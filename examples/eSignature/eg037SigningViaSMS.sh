# Send an envelope with three documents
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

source ./examples/eSignature/lib/utils.sh

# Choose a delivery method.
DELIVERY_METHOD="0"
echo "Please choose a delivery method:"
echo "Press 1 for SMS."
echo "Press 2 for WhatsApp."
read choice

case $choice in
    1) 
        DELIVERY_METHOD="SMS"
        ;;
    2) 
        DELIVERY_METHOD="WhatsApp"
        ;;
    *) 
        echo "Invalid choice. Select 1 or 2."
        ;;
esac

# Get a country code and phone number for the signer
GetSignerPhoneNum

# Get a country code and phone number for the CC recipient.
GetCCPhoneNum

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# ***DS.snippet.0.start
#  document 1 (html) has tag **signature_1**
#  document 2 (docx) has tag /sn1/
#  document 3 (pdf) has tag /sn1/
#
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - cc
#  The envelope will be sent first to the signer.
#  After it is signed, a copy is sent to the cc person.

# temp files:
request_data=$(mktemp /tmp/request-eg-002.XXXXXX)
response=$(mktemp /tmp/response-eg-002.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-002-doc1.XXXXXX)
doc2_base64=$(mktemp /tmp/eg-002-doc2.XXXXXX)
doc3_base64=$(mktemp /tmp/eg-002-doc3.XXXXXX)

# Fetch docs and encode
cat demo_documents/doc_1.html | base64 > $doc1_base64
cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc2_base64
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc3_base64

echo ""
echo "Sending the envelope request to DocuSign..."
echo "The envelope has three documents. Processing time will be about 15 seconds."
echo "Results:"
echo ""

# Concatenate the different parts of the request
#ds-snippet-start:eSign37Step2
printf \
'{
    "emailSubject": "Please sign this document set",
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
    "recipients": 
    {
        "carbonCopies": 
        [
            {
            "phoneNumber":
                {
                    "countryCode": "'"${CC_PHONE_COUNTRY}"'",
                    "number":"'"${CC_PHONE_NUMBER}"'"
                },
            "name": "'"${CC_NAME}"'",
            "recipientId": "2",
            "routingOrder": "2",
            "deliveryMethod": "'"${DELIVERY_METHOD}"'",
            }
        ],
        "signers": 
        [
            {
            "phoneNumber":
                {
                    "countryCode": "'"${SIGNER_PHONE_COUNTRY}"'",
                    "number":"'"${SIGNER_PHONE_NUMBER}"'"
                },
                "name": "'"${SIGNER_NAME}"'",
                "recipientId": "1",
                "routingOrder": "1",
                "deliveryMethod": "'"${DELIVERY_METHOD}"'",
                "tabs": 
                {
                    "signHereTabs": 
                    [
                        {
                            "anchorString": "**signature_1**",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        },
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
#ds-snippet-end:eSign37Step2

#ds-snippet-start:eSign37Step3
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response
#ds-snippet-end:eSign37Step3

echo ""
echo "Response:"
cat $response
echo ""

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
# Save the envelope id for use by other scripts
echo "EnvelopeId: ${envelope_id}"
echo ${envelope_id} > config/ENVELOPE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"
rm "$doc2_base64"
rm "$doc3_base64"

echo ""
echo ""
echo "Done."
echo ""