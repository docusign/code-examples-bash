# Use embedded sending:
# 1. create a draft envelope with three documents
# 2. Open the sending view of the DocuSign web tool
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# The sending editor can be opened in either of two views:
echo ""
PS3='Select the initial sending view: '
options=("Tagging view" "Recipients and documents view")
select opt in "${options[@]}"
do
    case $opt in
        "Tagging view")
            starting_view=tagging
            break
            ;;
        "Recipients and documents view")
            starting_view=recipient
            break
            ;;
    esac
done

# ***DS.snippet.0.start
# Create the document request body
#  document 1 (html) has tag **signature_1**
#  document 2 (docx) has tag /sn1/
#  document 3 (pdf) has tag /sn1/
# 
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - cc
#
#  The envelope is created with "created" (draft) status.
# 
#  The envelope will be sent first to the signer.
#  After it is signed, a copy is sent to the cc person.

# temp files:
request_data=$(mktemp /tmp/request-eg-011.XXXXXX)
response=$(mktemp /tmp/response-eg-011.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-011-doc1.XXXXXX)
doc2_base64=$(mktemp /tmp/eg-011-doc2.XXXXXX)
doc3_base64=$(mktemp /tmp/eg-011-doc3.XXXXXX)

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
printf \
'{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Order acknowledgement",
            "fileExtension": "html", "documentId": "1"
        },
        {
            "documentBase64": "' >> $request_data
            cat $doc2_base64 >> $request_data
            printf '",
            "name": "Battle Plan",
            "fileExtension": "docx", "documentId": "2"
        },
        {
            "documentBase64": "' >> $request_data
            cat $doc3_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf", "documentId": "3"
        }
    ],
    "recipients": {
        "carbonCopies": [
            {
                "email": "'${CC_EMAIL}'", "name": "'"${CC_NAME}"'",
                "recipientId": "2", "routingOrder": "2"
            }
        ],
        "signers": [
            {
                "email": "'${SIGNER_EMAIL}'", "name": "'"${SIGNER_NAME}"'",
                "recipientId": "1", "routingOrder": "1",
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "**signature_1**",
                            "anchorUnits": "pixels", "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        },
                        {
                            "anchorString": "/sn1/",
                            "anchorUnits": "pixels", "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        }
                    ]
                }
            }
        ]
    },
    "status": "created"
}' >> $request_data

curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response

echo ""
cat $response
# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

echo ""
echo "Requesting the sender view url"

# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the embedded sending completes.
# For this example, we'll use http://httpbin.org/get to show the 
# query parameters passed back from DocuSign
curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary "{\"returnUrl\": \"http://httpbin.org/get\"}" \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/views/sender \
     --output $response

echo ""
cat $response
sending_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`
# Next, we update the returned url if we want to start with the Recipient
# and Documents view
if [ "$starting_view" = "recipient" ]; then
   sending_url=`printf "${sending_url/send=1/send=0}"`
fi
# ***DS.snippet.0.end

echo ""
printf "The embedded sending URL is ${sending_url}\n"
printf "It is only valid for five minutes. Attempting to automatically open your browser...\n"
if which xdg-open &> /dev/null  ; then
  xdg-open "$sending_url"
elif which open &> /dev/null    ; then
  open "$sending_url"
elif which start &> /dev/null   ; then
  start "$sending_url"
fi

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
