# Bulk sending envelopes to multiple recipients

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check for a valid cc email and prompt the user if 
# CC_EMAIL and CC_NAME haven't been set in the config file.
# source ./examples/eSignature/lib/utils.sh
# CheckForValidCCEmail
read -p "Please enter Bulk copy #1 signer email address: " SIGNER1_EMAIL
read -p "Please enter Bulk copy #1 signer name: " SIGNER1_NAME
read -p "Please enter Bulk copy #1 carbon copy email address: " CC1_EMAIL
read -p "Please enter Bulk copy #1 carbon copy name: " CC1_NAME
read -p "Please enter Bulk copy #2 signer email address: " SIGNER2_EMAIL
read -p "Please enter Bulk copy #2 signer name: " SIGNER2_NAME
read -p "Please enter Bulk copy #2 carbon copy email address: " CC2_EMAIL
read -p "Please enter Bulk copy #2 carbon copy name: " CC2_NAME

# temp file
doc1_base64=$(mktemp /tmp/eg-031-doc1.XXXXXX)

# Fetch doc and encode
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://demo.docusign.net/restapi"

# Construct your API headers
#ds-snippet-start:eSign031Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json, text/plain, */*" \
					'--header' "Content-Type: application/json;charset=UTF-8" \
					'--header' "Accept-Encoding: gzip, deflate, br" \
					'--header' "Accept-Language: en-US,en;q=0.9")
#ds-snippet-end:eSign031Step2

# Submit the Bulk List
# Create a temporary file to store the JSON body
# The JSON body must contain the recipient role, recipientId, name, and email.
request_data=$(mktemp /tmp/request-bs.XXXXXX)

#ds-snippet-start:eSign031Step3
printf \
'{
	"name": "sample.csv",
	"bulkCopies": [{
		"recipients": [{
			"roleName": "signer",
			"name": "'"${SIGNER1_NAME}"'",
			"email": "'"${SIGNER1_EMAIL}"'"
		},
		{
			"roleName": "cc",
			"name": "'"${CC1_NAME}"'",
			"email": "'"${CC1_EMAIL}"'"
		}],
		"customFields": []
	},
  {
		"recipients": [{
			"roleName": "signer",
			"name": "'"${SIGNER2_NAME}"'",
			"email": "'"${SIGNER2_EMAIL}"'"
		},
		{
			"roleName": "cc",
			"name": "'"${CC2_NAME}"'",
			"email": "'"${CC2_EMAIL}"'"
		}],
		"customFields": []
	}]
}	
' >> $request_data					
					
# Make a POST call to the bulk_send_lists endpoint, this will be referenced in future API calls.
# Display the JSON structure of the API response
# Create a temporary file to store the response
echo ""
echo "Posting Bulk Send List"
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/bulk_send_lists \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Posting of the Bulk List has failed"
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

#Obtain the BULK_LIST_ID from the JSON response
BULK_LIST_ID=`cat $response | grep listId | sed 's/.*\"listId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign031Step3

# Remove the temporary files
rm "$request_data"
rm "$response"


# Create your draft envelope
# Create a temporary file to store the JSON body
#ds-snippet-start:eSign031Step4
request_data=$(mktemp /tmp/request-bs.XXXXXX)
printf \
'{
	"documents": [{
		"documentBase64": "' >> $request_data
		cat $doc1_base64 >> $request_data
		printf '",
		"name": "Lorem Ipsum",
		"fileExtension": "pdf",
		"documentId": "1"
	}],
	"envelopeIdStamping": "true",
	"emailSubject": "Please sign",
	"recipients": {
		"signers": [{
			"name": "Multi Bulk Recipient::signer",
			"email": "multiBulkRecipients-signer@docusign.com",
			"roleName": "signer",
			"routingOrder": "1",
			"recipientId" : "1",
			"recipientType" : "signer",
			"deliveryMethod" : "Email",
			"status": "created",
			"tabs": {
				"signHereTabs": [{
					"documentId": "1",
					"name": "SignHereTab",
					"pageNumber": "1",
					"recipientId": "1",
					"tabLabel": "SignHereTab",
					"xPosition": "200",
					"yPosition": "160"
				}]}
			}],
		"carbonCopies": [{
			"name": "Multi Bulk Recipient::cc",
			"email": "multiBulkRecipients-cc@docusign.com",
			"roleName": "cc",
			"routingOrder": "2",
			"recipientId" : "2",
			"recipientType" : "cc",
			"deliveryMethod" : "Email",
			"status": "created"
			}]
		},		
	"status": "created"
}	
' >> $request_data

echo ""
echo "Creating a draft envelope."
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Creation of the draft envelope has failed"
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

#Obtain the envelopeId from the API response.
ENVELOPE_ID=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign031Step4

#Remove the temporary files
rm "$response"
rm "$request_data"

# Add an envelope custom field set to the value of your listId
# This Custom Field is used for tracking your Bulk Send via the Envelopes::Get method
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-bs.XXXXXX)
#ds-snippet-start:eSign031Step5
printf \
'{
	"listCustomFields": [],
	"textCustomFields": [{
		"name": "mailingListId",
		"required": false,
		"show": false,
		"value": "'"$BULK_LIST_ID"'"
	}]
}	
' >> $request_data
echo ""
echo "Adding the listId as an envelope custom field."
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${ENVELOPE_ID}/custom_fields \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
#ds-snippet-end:eSign031Step5

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Addition of the listId to the envelope has failed"
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

#Remove the temporary file

rm "$response"
rm "$request_data"

# Initiate the Bulk Send by posting your listId obtained from Step 3, and the envelopeId obtained in step 4.
# Target endpoint: {ACCOUNT_ID}/bulk_send_lists/{LIST_ID}/send
#ds-snippet-start:eSign031Step6
printf \
'{
	"listId": "'"${BULK_LIST_ID}"'",
	"envelopeOrTemplateId": "'"${ENVELOPE_ID}"'",
}	
' >> $request_data

echo ""
echo "Initiating the Bulk Send."
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/bulk_send_lists/${BULK_LIST_ID}/send \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Initiating the Bulk Send has failed"
    echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

batchId=`cat $response | grep batchId | sed 's/.*\"batchId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign031Step6

rm "$response"
rm "$request_data"

# Confirm Bulk Send has initiated.
# Note: Depending on the number of Bulk Recipients, it may take some time for the Bulk Send to complete. For 2000 recipients this can take ~1 hour.
#ds-snippet-start:eSign031Step7
echo ""
echo "Confirming Bulk Send has initiated. -- ${batchId}"
echo ""

sleep 10s

response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/accounts/${account_id}/bulk_send_batch/${batchId} \
     "${Headers[@]}" \
     --output ${response})
#ds-snippet-end:eSign031Step7

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Initiating the Bulk Send has failed"
    echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
echo ""
cat $response
#Remove the temporary file
rm "$response"


echo ""
echo ""
echo "Done."
echo ""
