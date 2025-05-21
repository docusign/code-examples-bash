# Create a template. First, the account's templates are listed.
# If one of the templates is named "Example Signer and CC template"
# then the template will not be created.

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
# Step 1. List the account's templates
echo ""
echo "Checking to see if the template already exists in your account..."
echo ""
template_name="Example Signer and CC template v2"
response=$(mktemp /tmp/response-eg-008.XXXXXX)
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --get \
     --data-urlencode "search_text=${template_name}" \
     --request GET ${base_path}/v2.1/accounts/${account_id}/templates \
     --output $response

 echo "Did we find any templateIds?: " 
 cat $response
# pull out the templateId if it was returned
TEMPLATE_ID=`cat $response | grep templateId | sed 's/.*\"templateId\":\"//' | sed 's/\",.*//'`

echo $TEMPLATE_ID

if [ "${TEMPLATE_ID}" != "" ]; then
    echo ""
    echo "Your account already includes the '${template_name}' template."
    # Save the template id for use by other scripts
    echo "${TEMPLATE_ID}" > config/TEMPLATE_ID
    rm "$response"
    echo ""
    echo "Done."
    echo ""
    exit 0
fi

# Step 2. Create the template programmatically
# 
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - cc
#  The envelope will be sent first to the signer.
#  After it is signed, a copy is sent to the cc person.

# temp files:
request_data=$(mktemp /tmp/request-eg-008.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-008-doc1.XXXXXX)

echo ""
echo "Sending the template create request to DocuSign..."
echo ""

# Fetch document and encode
cat demo_documents/World_Wide_Corp_fields.pdf | base64 > $doc1_base64

# Concatenate the different parts of the request
#ds-snippet-start:eSign8Step2
printf \
'{
    "description": "Example template created via the API",
    "name": "Example Signer and CC template v2",
    "shared": "false",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "documentId": "1", "fileExtension": "pdf",
            "name": "Lorem Ipsum"
        }
    ],
    "emailSubject": "Please sign this document",
   "recipients": {
        "carbonCopies": [
            {"recipientId": "2", "roleName": "cc", "routingOrder": "2"}
        ],
        "signers": [
            {
                "recipientId": "1", "roleName": "signer", "routingOrder": "1",
                "tabs": {
                    "checkboxTabs": [
                        {
                            "documentId": "1", "pageNumber": "1",
                            "tabLabel": "ckAuthorization", "xPosition": "75",
                            "yPosition": "417"
                        },
                        {
                            "documentId": "1", "pageNumber": "1",
                            "tabLabel": "ckAuthentication", "xPosition": "75",
                            "yPosition": "447"
                        },
                        {
                            "documentId": "1", "pageNumber": "1",
                            "tabLabel": "ckAgreement", "xPosition": "75",
                            "yPosition": "478"
                        },
                        {
                            "documentId": "1", "pageNumber": "1",
                            "tabLabel": "ckAcknowledgement", "xPosition": "75",
                            "yPosition": "508"
                        }
                    ],
                    "listTabs": [
                        {
                            "documentId": "1", "font": "helvetica", 
                            "fontSize": "size14",
                            "listItems": [
                                {"text": "Red", "value": "red"},
                                {"text": "Orange", "value": "orange"},
                                {"text": "Yellow", "value": "yellow"},
                                {"text": "Green", "value": "green"},
                                {"text": "Blue", "value": "blue"},
                                {"text": "Indigo", "value": "indigo"},
                                {"text": "Violet", "value": "violet"}
                            ],
                            "pageNumber": "1", "required": "false", 
                            "tabLabel": "list", "xPosition": "142",
                            "yPosition": "291"
                        }
                    ],
                    "radioGroupTabs": [
                        {
                            "documentId": "1", "groupName": "radio1",
                            "radios": [
                                {
                                    "pageNumber": "1", "required": "false",
                                    "value": "white", "xPosition": "142",
                                    "yPosition": "384"
                                },
                                {
                                    "pageNumber": "1", "required": "false",
                                    "value": "red", "xPosition": "74",
                                    "yPosition": "384"
                                },
                                {
                                    "pageNumber": "1", "required": "false",
                                    "value": "blue", "xPosition": "220",
                                    "yPosition": "384"
                                }
                            ]
                        }
                    ],
                    "signHereTabs": [
                        {
                            "documentId": "1", "pageNumber": "1",
                            "xPosition": "191", "yPosition": "148"
                        }
                    ],
                    "textTabs": [
                        {
                            "documentId": "1", "font": "helvetica",
                            "fontSize": "size14", "height": 23, 
                            "pageNumber": "1", "required": "false",
                            "tabLabel": "text", "width": 84,
                            "xPosition": "153", "yPosition": "230"
                        }
                    ],
                    "numericalTabs" : [
                        {
                            "validationType": "Currency",
                            "documentId": "1", "font": "helvetica",
                            "fontSize": "size14", "height": 23,
                            "pageNumber": "1", "required": "false",
                            "tabLabel": "numericalCurrency", "width": 84,
                            "xPosition": "153", "yPosition": "260"
                        }]
                }
            }
        ]
    },
    "status": "created"
}' >> $request_data
#ds-snippet-end:eSign8Step2

#ds-snippet-start:eSign8Step3
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/templates \
     --output $response
#ds-snippet-end:eSign8Step3

echo ""
echo "Results:"
cat $response

# pull out the template id
TEMPLATE_ID=`cat $response | grep templateId | sed 's/.*\"templateId\":\"//' | sed 's/\",.*//'`
# ***DS.snippet.0.end
echo ""
echo "Template '${template_name}' was created! Template ID ${TEMPLATE_ID}."
# Save the template id for use by other scripts
echo ${TEMPLATE_ID} > config/TEMPLATE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""

