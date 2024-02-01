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

# Step 1. List the account's templates
echo ""
echo "Checking to see if the template already exists in your account..."
echo ""
template_name="Web Form Example Template"
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
cat demo_documents/World_Wide_Corp_Web_Form.pdf | base64 > $doc1_base64

# Concatenate the different parts of the request
printf \
'{
    "description": "Example template created via the API",
    "name": "Web Form Example Template",
    "shared": "false",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "documentId": "1", "fileExtension": "pdf",
            "name": "World_Wide_Web_Form"
        }
    ],
    "emailSubject": "Please sign this document",
   "recipients": {
        "signers": [
            {
                "recipientId": "1", "roleName": "signer", "routingOrder": "1",
                "tabs": {
                    "checkboxTabs": [
                        {
                            "documentId": "1", "tabLabel": "Yes", 
                            "anchorString": "/SMS/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        }
                    ],
                    "signHereTabs": [
                        {
                            "documentId": "1", "tabLabel": "Signature", 
                            "anchorString": "/SignHere/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        }
                    ],
                    "textTabs": [
                        {
                            "documentId": "1", "tabLabel": "FullName", 
                            "anchorString": "/FullName/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        },
                        {
                            "documentId": "1", "tabLabel": "PhoneNumber", 
                            "anchorString": "/PhoneNumber/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        },
                        {
                            "documentId": "1", "tabLabel": "Company", 
                            "anchorString": "/Company/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        },
                        {
                            "documentId": "1", "tabLabel": "JobTitle", 
                            "anchorString": "/Title/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        }
                    ],
                    "dateSignedTabs": [
                        {
                            "documentId": "1", "tabLabel": "DateSigned", 
                            "anchorString": "/Date/", "anchorUnits": "pixels", 
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        }
                    ]
                }
            }
        ]
    },
    "status": "created"
}' >> $request_data


curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/templates \
     --output $response

echo ""
echo "Results:"
cat $response

# pull out the template id
TEMPLATE_ID=`cat $response | grep templateId | sed 's/.*\"templateId\":\"//' | sed 's/\",.*//'`

echo ""
echo "Template '${template_name}' was created! Template ID ${TEMPLATE_ID}."
# Save the template id for use by other scripts
echo ${TEMPLATE_ID} > config/WEB_FORM_TEMPLATE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""

