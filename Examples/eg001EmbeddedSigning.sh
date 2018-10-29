# Embedded signing ceremony
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

source ../Env.txt

#
# Step 1. Create the envelope.
#         The signer recipient includes a clientUserId setting
# Step 2. Create a recipient view (a signing ceremony view)
#         that the signer will directly open in their browser to sign.

#  Step 1...
#
#  document 1 (pdf) has tag /sn1/ 
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - cc
#  The envelope will be sent first to the signer.
#  After it is signed, a copy is sent to the cc person.

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-001-doc1.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

# Fetch doc and encode
cat ../demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64
# Concatenate the different parts of the request
printf \
'{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "documentBase64": "' > $request_data
cat $doc1_base64 >> $request_data
printf \
'",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
    "recipients": {
        "carbonCopies": [
            {
                "email": "{USER_EMAIL}",
                "name": "Charles Copy",
                "recipientId": "2",
                "routingOrder": "2"
            }
        ],
        "signers": [
            {
                "email": "{USER_EMAIL}",
                "name": "{USER_FULLNAME}",
                "recipientId": "1",
                "routingOrder": "1",
                "clientUserId": "1000",
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

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST https://demo.docusign.net/restapi/v2/accounts/{ACCOUNT_ID}/envelopes
     --output ${response}

echo ""
echo "Response:"
cat $response

# pull out the envelopeId
ENVELOPE_ID=`sed 's/{\"access_token\":\"//' $response |
sed 's/\",\"token_type\":\"Bearer\"\,\"refresh_token\":\".*\",\"expires_in\":.*}//'` 


#echo ""
#echo ""
#echo "Files"
#echo "$request_data"
#echo "$doc1_base64"
#echo "$doc2_base64"
#echo "$doc3_base64"

# cleanup
rm "$request_data"
rm "$doc1_base64"
rm "$doc2_base64"
rm "$doc3_base64"

echo ""
echo ""
echo "Done."
echo ""


