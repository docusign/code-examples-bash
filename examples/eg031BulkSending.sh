# Bulk sending envelopes to multiple recipients

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Step 1: Create your API Headers
# Note: These values are not valid, but are shown for example purposes only!
access_token=$(cat config/ds_access_token.txt)
account_id=$API_ACCOUNT_ID
base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
					'--header' "Accept: application/json, text/plain, */*" \
					'--header' "Content-Type: application/json;charset=UTF-8" \
					'--header' "Accept-Encoding: gzip, deflate, br" \
					'--header' "Accept-Language: en-US,en;q=0.9")
			
# Step 3: Submit the Bulk List
# Create a temporary file to store the JSON body
# The JSON body must contain the recipient role, recipientId, name, and email.
request_data=$(mktemp /tmp/request-bs.XXXXXX)
printf \
'{
	"name": "sample.csv",
	"bulkCopies": [{
		"recipients": [{
			"recipientId": "1",
			"role": "signer",
			"tabs": [],
			"name": "'"${SIGNER_NAME}"'",
			"email": "'"${SIGNER_EMAIL}"'"
		},
		{
			"recipientId": "2",
			"role": "cc",
			"tabs": [],
			"name": "'"${CC_NAME}"'",
			"email": "'"${CC_EMAIL}"'"
		}],
		"customFields": []
	},
  {
		"recipients": [{
			"recipientId": "1",
			"role": "signer",
			"tabs": [],
			"name": "'"${SIGNER_NAME}"'",
			"email": "'"${SIGNER_EMAIL}"'"
		},
		{
			"recipientId": "2",
			"role": "cc",
			"tabs": [],
			"name": "'"${CC_NAME}"'",
			"email": "'"${CC_EMAIL}"'"
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
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

#Obtain the BULK_LIST_ID from the JSON response
BULK_LIST_ID=`cat $response | grep listId | sed 's/.*\"listId\":\"//' | sed 's/\",.*//'`

# Remove the temporary files
rm "$request_data"
rm "$response"


# Step 4 : Create your draft envelope
# Create a temporary file to store the JSON body

base64="DQoNCg0KCQkJCXRleHQgZG9jDQoNCg0KDQoNCg0KUk0gIwlSTSAjCVJNICMNCg0KDQoNClxzMVwNCg0KLy9hbmNoMSANCgkvL2FuY2gyDQoJCS8vYW5jaDM="
request_data=$(mktemp /tmp/request-bs.XXXXXX)
printf \
'{
	"documents": [{
		"documentBase64": "'"$base64"'",
		"documentId": "1",
		"fileExtension": "txt",
		"name": "NDA"
	}],
	"envelopeIdStamping": "true",
	"emailSubject": "Please sign",
	"recipients": {
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
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

#Obtain the envelopeId from the API response.
ENVELOPE_ID=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

#Remove the temporary files
rm "$response"
rm "$request_data"

# Step 5: Add an envelope custom field set to the value of your listId
# This Custom Field is used for tracking your Bulk Send via the Envelopes::Get method
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-bs.XXXXXX)
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

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Addition of the listId to the envelope has failed"
	echo ""
	cat $response
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

#Remove the temporary file

rm "$response"
rm "$request_data"

# Step 6: Add placeholder recipients. These will be replaced by the details provided in the Bulk List uploaded during Step 2
# Note: The name / email format used is:
#		Name: Multi Bulk Recipients::{rolename}
#		Email: MultiBulkRecipients-{rolename}@docusign.com

# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-bs.XXXXXX)
printf \
'{
	"signers": [{
		"name": "Multi Bulk Recipient::signer",
		"email": "multiBulkRecipients-signer@docusign.com",
		"roleName": "signer",
		"note": "",
		"routingOrder": 1,
		"status": "created",
		"templateAccessCodeRequired": null,
		"deliveryMethod": "email",
		"recipientId": "1",
		"recipientType": "signer"
	},
	{
		"name": "Multi Bulk Recipient::cc",
		"email": "multiBulkRecipients-cc@docusign.com",
		"roleName": "cc",
		"note": "",
		"routingOrder": 1,
		"status": "created",
		"templateAccessCodeRequired": null,
		"deliveryMethod": "email",
		"recipientId": "2",
		"recipientType": "signer"
	}]
}	
' >> $request_data

echo ""
echo "Adding placeholder recipients to the envelope."
echo ""
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${ENVELOPE_ID}/recipients \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Addition of the placeholder recipients has failed"
    echo ""
	cat $response
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

#Remove the temporary file

rm "$response"
rm "$request_data"

# Step 7: Initiate the Bulk Send by posting your listId obtained from Step 2, and the envelopeId obtained in step 4.
# Target endpoint: {ACCOUNT_ID}/bulk_send_lists/{LIST_ID}/send
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
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

batchId=`cat $response | grep batchId | sed 's/.*\"batchId\":\"//' | sed 's/\",.*//'`

rm "$response"
rm "$request_data"

#Step 8: Confirm Bulk Send has initiated.
#Note: Depending on the number of Bulk Recipients, it may take some time for the Bulk Send to complete. For 2000 recipients this can take ~1 hour.

echo ""
echo "Confirming Bulk Send has initiated. -- ${batchId}"
echo ""

sleep 10s

response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/accounts/${account_id}/bulk_envelopes/${batchId} \
     "${Headers[@]}" \
     --output ${response})
	 
#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Initiating the Bulk Send has failed"
    echo ""
	cat $response
	exit 1
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

