# Use embedded signing from template with added document

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check for a valid cc email and prompt the user if 
#CC_EMAIL and CC_NAME haven't been set in the config file.
source ./examples/eSignature/lib/utils.sh
CheckForValidCCEmail

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Check that we have a template id
if [ ! -f config/TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: A template id is needed. Fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit 0
fi
template_id=`cat config/TEMPLATE_ID`

# temp files:
request_data=$(mktemp /tmp/request-eg-013.XXXXXX)
response=$(mktemp /tmp/response-eg-013.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-013-doc1.XXXXXX)

# Fetch docs and encode
cat demo_documents/added_document.html | base64 > $doc1_base64

echo ""
echo "Sending the envelope request to DocuSign..."
echo "A template is used, it has one document. A second document will be"
echo "added by using Composite Templates"

# Concatenate the different parts of the request
#  document 1 (html) has tag **signature_1**
#ds-snippet-start:eSign13Step2
printf \
'{
    "compositeTemplates": [
        {
            "compositeTemplateId": "1",
            "inlineTemplates": [
                {
                    "recipients": {
                        "carbonCopies": [
                            {
                                "email": "'"${CC_EMAIL}"'",
                                "name": "'"${CC_NAME}"'",
                                "recipientId": "2",
                                "roleName": "cc"
                            }
                        ],
                        "signers": [
                            {
                                "clientUserId": "1000",
                                "email": "'"${SIGNER_EMAIL}"'",
                                "name": "'"${SIGNER_NAME}"'",
                                "recipientId": "1",
                                "roleName": "signer"
                            }
                        ]
                    },
                    "sequence": "2"
                }
            ],
            "serverTemplates": [
                {
                    "sequence": "1",
                    "templateId": "' > $request_data
                    printf "${template_id}" >> $request_data
                    printf '"
                }
            ]
        },
        {
            "compositeTemplateId": "2",
            "document": {
                "documentBase64": "' >> $request_data
                cat $doc1_base64 >> $request_data
                printf '",
                "documentId": "1",
                "fileExtension": "html",
                "name": "Appendix 1--Sales order"
            },
            "inlineTemplates": [
                {
                    "recipients": {
                        "carbonCopies": [
                            {
                                "email": "'${CC_EMAIL}'",
                                "name": "'"${CC_NAME}"'",
                                "recipientId": "2",
                                "roleName": "cc"
                            }
                        ],
                        "signers": [
                            {
                                "email": "'"${SIGNER_EMAIL}"'",
                                "name": "'"${SIGNER_NAME}"'",
                                "recipientId": "1",
                                "roleName": "signer",
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
                            }
                        ]
                    },
                    "sequence": "1"
                }
            ]
        }
    ],
    "status": "sent"
}' >> $request_data
#ds-snippet-end:eSign13Step2

#ds-snippet-start:eSign13Step3
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response
#ds-snippet-end:eSign13Step3

echo ""
echo "Results:"
echo ""
cat $response

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
echo "EnvelopeId: ${envelope_id}"
# Step 2. Create a recipient view (an embedded signing view)
#         that the signer will directly open in their browser to sign.
#
# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the 
# query parameters passed back from DocuSign

echo ""
echo "Requesting the url for the embedded signing..."
#ds-snippet-start:eSign13Step4
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary '
{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "'"${SIGNER_EMAIL}"'",
    "userName": "'"${SIGNER_NAME}"'",
    "clientUserId": 1000,
}' \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/views/recipient \
     --output ${response}
#ds-snippet-end:eSign13Step4

echo ""
echo "Response:"
cat $response
echo ""

signing_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`
echo ""
printf "The embedded signing URL is ${signing_url}\n"
printf "It is only valid for five minutes. Attempting to automatically open your browser...\n"
if which xdg-open &> /dev/null  ; then
  xdg-open "$signing_url"
elif which open &> /dev/null    ; then
  open "$signing_url"
elif which start &> /dev/null   ; then
  start "$signing_url"
fi

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""