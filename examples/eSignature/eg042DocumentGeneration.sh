#!/bin/bash
# https://developers.docusign.com/docs/esign-rest-api/request-signature-data-fields
# How to request a remote signature with data fields
#
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
base_path="https://demo.docusign.net/restapi"

echo "Create template"
#  The template has one placeholder recipient.
#  recipient 1 - signer
#  The envelope will be sent to the signer

# temp files:
doc1_base64=$(mktemp /tmp/eg-042-doc1.XXXXXX)
request_data=$(mktemp /tmp/request-eg-042.XXXXXX)
response=$(mktemp /tmp/response-eg-042.XXXXXX)

echo ""
echo "Sending the template create request to DocuSign..."
echo ""

#ds-snippet-start:eSign42Step2
printf \
'{
    "description": "Example template created via the API",
    "name": "Example document generation template",
    "shared": false,
    "emailSubject": "Please sign this document",
    "status": "created",
    "recipients": {
         "signers": [
              {
                 "recipientId": "1", "roleName": "signer", "routingOrder": "1"
              }
          ]
    }
}' >> $request_data

Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --data-binary @${request_data} \
    --request POST ${base_path}/v2.1/accounts/${account_id}/templates \
    --output ${response})

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo ""
	cat $response
	exit 0
fi

# pull out the template id
template_id=`cat $response | grep templateId | sed 's/.*\"templateId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign42Step2

echo ""
echo "Template was created! Template ID ${template_id}."
rm "$response"
rm "$request_data"

# Add a document with merge fields to your template
#ds-snippet-start:eSign42Step3
# Fetch document and encode
cat demo_documents/Offer_Letter_Dynamic_Table.docx | base64 > $doc1_base64

printf \
'{
  "documents": [
        {
            "documentBase64": "' >> $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "documentId": "1", "fileExtension": "docx", "order":"1","pages":"1",
            "name": "OfferLetterDemo.docx"
        }
    ]
}' >> $request_data

Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data-binary @${request_data} \
  --request PUT ${base_path}/v2.1/accounts/${account_id}/templates/${template_id}/documents/1 \
  --output ${response})
#ds-snippet-end:eSign42Step3

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to add document to template."
	echo ""
	cat $response
	exit 0
fi

echo "Document created!"

rm "$response"
rm "$request_data"

# Add tabs to the template
#ds-snippet-start:eSign42Step4
printf \
'{
    "signHereTabs": [
        {
            "anchorString": "Employee Signature",
            "anchorUnits": "pixels",
            "anchorXOffset": "5",
            "anchorYOffset": "-22"
        }
    ],
    "dateSignedTabs": [
        {
            "anchorString": "Date Signed",
            "anchorUnits": "pixels",
            "anchorYOffset": "-22"
        }
    ]
}' >> $request_data


Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-binary @${request_data} \
  --request POST ${base_path}/v2.1/accounts/${account_id}/templates/${template_id}/recipients/1/tabs \
  --output ${response})
#ds-snippet-end:eSign42Step4

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Envelope creation failed."
	echo ""
	cat $response
	exit 0
fi

echo "Tabs created"

rm "$response"
rm "$request_data"

# Create an envelope draft from a template
#ds-snippet-start:eSign42Step5
printf \
'{
    "templateId": "'"${template_id}"'",
    "templateRoles": [
        {
            "email": "'"${SIGNER_EMAIL}"'",
            "name": "'"${SIGNER_NAME}"'",
            "roleName": "signer"
        }
    ],
    "status": "created"
}' >> $request_data

echo ""
echo "Sending the envelope request to DocuSign..."

Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-binary @${request_data} \
  --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
  --output ${response})

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Envelope creation failed."
	echo ""
	cat $response
	exit 0
fi

envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign42Step5

echo ""
echo "Envelope was created! Envelope ID: ${envelope_id}."


# Get DocGenFormFields
#ds-snippet-start:eSign42Step6
Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
      --header "Accept: application/json" \
      --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/docGenFormFields \
      --output ${response})

echo $Status
if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to fetch docGenFormFields."
	echo ""
	cat $response
	exit 0
fi

echo "DocGenFormFields: "
cat $response

# Retrieve the document id
document_id=`cat $response | grep documentId | sed 's/.*\"documentId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign42Step6

echo ""
echo "Document ID GUID: ${document_id}."
rm "$response"
rm "$request_data"

echo "Please input Candidate name:"
read CANDIDATE_NAME

PS3='Please select a job title:'
select choice in \
  "Software Engineer" \
  "Account Executive"; do
  echo $choice
  JOB_TITLE=$choice
  break
done

echo "Please input the manager name:"
read MANAGER_NAME

echo "Please input the start date in the format MM/DD/YYYY:"
read START_DATE

echo "Please input the salary:"
read -p "$" SALARY

echo "Please input the RSUs:"
read RSUS

# Merge data fields with the eSignature REST API
#ds-snippet-start:eSign42Step7
printf \
'{
  "docGenFormFields": [
    {
      "documentId": "'"${document_id}"'",
      "docGenFormFieldList": [
        {
          "name": "Candidate_Name",
          "value": "'"${CANDIDATE_NAME}"'"
        },
        {
          "name": "Job_Title",
          "value": "'"${JOB_TITLE}"'"
        },
        {
          "name": "Manager_Name",
          "value": "'"${MANAGER_NAME}"'"
        },
        {
          "name": "Start_Date",
          "value": "'"${START_DATE}"'"
        },
        {
          "name": "Compensation_Package",
          "type": "TableRow",
          "rowValues": [
            {
              "docGenFormFieldList": [
                {
                  "name": "Compensation_Component",
                  "value": "Salary"
                },
                {
                  "name": "Details",
                  "value": "$'"${SALARY}"'"
                }
              ]
            },
            {
              "docGenFormFieldList": [
                {
                  "name": "Compensation_Component",
                  "value": "Bonus"
                },
                {
                  "name": "Details",
                  "value": "20%%"
                }
              ]
            },
            {
              "docGenFormFieldList": [
                {
                  "name": "Compensation_Component",
                  "value": "RSUs"
                },
                {
                  "name": "Details",
                  "value": '${RSUS}'
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}' >> $request_data

Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
      --header "Content-Type: application/json" \
      --data-binary @${request_data} \
      --request PUT ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/docgenformfields \
      --output ${response})
#ds-snippet-end:eSign42Step7

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to merge fields."
	echo ""
	cat $response
	exit 0
fi

echo "Merge succeeded!"

rm "$response"
rm "$request_data"

# Send the envelope with the eSignature REST API
#ds-snippet-start:eSign42Step8
printf \
'{
    "status": "sent"
}' >> $request_data

Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-binary @${request_data} \
  --request PUT ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id} \
  --output ${response})
#ds-snippet-end:eSign42Step8

if [[ "$Status" -gt "201" ]] ; then
  echo ""
	echo "Failed to send envelope."
	echo ""
	cat $response
	exit 0
fi

echo "Envelope Sent!"
cat $response

# cleanup
  rm "$doc1_base64"
  rm "$response"
  rm "$request_data"

  echo ""
  echo ""
  echo "Done."
  echo ""
