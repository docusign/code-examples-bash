# Set document visibility in an envelope with three documents
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

# Construct your API headers
#ds-snippet-start:eSign40Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:eSign40Step2

#  document 1 (html) has tag **signature_1**
#  document 2 (docx) has tag /sn1/
#  document 3 (pdf) has tag /sn1/
#
#  The envelope has three recipients.
#  recipient 1 - signer1
#  recipient 2 - signer2
#  recipient 3 - cc
#  The envelope will be sent first to the signer1 who will be able to sign the first document.
#  The second and third document will not be visible to signer1.
#  Signer2 will be able to sign the second and third documents. The first document will not be
#  visible to signer 2.
#  After both signers have completed signing, a copy is sent to the cc person who will be able
#  to see all documents.

read -p "Please enter signer #1 email address: " SIGNER1_EMAIL
read -p "Please enter signer #1 name: " SIGNER1_NAME
read -p "Please enter signer #2 email address: " SIGNER2_EMAIL
read -p "Please enter signer #2 name: " SIGNER2_NAME
read -p "Please enter carbon copy email address: " CC_EMAIL
read -p "Please enter carbon copy name: " CC_NAME

# temp files:
request_data=$(mktemp /tmp/request-eg-040.XXXXXX)
response=$(mktemp /tmp/response-eg-040.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-040-doc1.XXXXXX)
doc2_base64=$(mktemp /tmp/eg-040-doc2.XXXXXX)
doc3_base64=$(mktemp /tmp/eg-040-doc3.XXXXXX)

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
#ds-snippet-start:eSign40Step3
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
    "recipients": {
        "carbonCopies": [
            {
                "email": "'"${CC_EMAIL}"'",
                "name": "'"${CC_NAME}"'",
                "recipientId": "3",
                "routingOrder": "2"
            }
        ],
        "signers": [
            {
                "email": "'"${SIGNER1_EMAIL}"'",
                "name": "'"${SIGNER1_NAME}"'",
                "recipientId": "1",
                "routingOrder": "1",
                "excludedDocuments": [2, 3],
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "**signature_1**",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        }
                    ]
                }
            },
            {
                "email": "'"${SIGNER2_EMAIL}"'",
                "name": "'"${SIGNER2_NAME}"'",
                "recipientId": "2",
                "routingOrder": "1",
                "excludedDocuments": [1],
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
#ds-snippet-end:eSign40Step3

#ds-snippet-start:eSign40Step4
response=$(mktemp /tmp/response-oa.XXXXXX)
Status=$(curl --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})
#ds-snippet-end:eSign40Step4

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Can't get user's data..."
    echo ""
    cat $response
    echo ""
    exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

errorCode=`cat $response | grep errorCode | sed 's/.*\"errorCode\":\"//' | sed 's/\",.*//'`

if [[ $errorCode == "ACCOUNT_LACKS_PERMISSIONS" ]]; then
  echo ""
  echo "See https://developers.docusign.com/docs/esign-rest-api/how-to/set-document-visibility in the DocuSign \
Developer Center for instructions on how to enable document visibility in your developer account."
  echo ""
else
  # pull out the envelopeId
  envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

  # Save the envelope id for use by other scripts
  echo "EnvelopeId: ${envelope_id}"
  echo ""
  echo ""
  echo "Done."
  echo ""
fi

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"
rm "$doc2_base64"
rm "$doc3_base64"
