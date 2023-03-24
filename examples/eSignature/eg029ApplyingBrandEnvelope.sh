# Applying a Brand to an envelope

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that we have a brand id
if [ ! -f config/BRAND_ID ]; then
    echo ""
    echo "PROBLEM: Brand Id is needed. To fix: execute script eg028CreateingABrand.sh"
    echo ""
    exit -1
fi
brand_id=`cat config/BRAND_ID`


# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
brand_id=$brand_id
base_path="https://demo.docusign.net/restapi"

#Step 2: Construct your API headers
#ds-snippet-start:eSign29Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

#ds-snippet-end:eSign29Step2

# Step 3: Construct the request body
# Create a temporary file to store the request body
#ds-snippet-start:eSign29Step3
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
'{
	"documents": [{
		"documentBase64": "DQoNCg0KCQkJCXRleHQgZG9jDQoNCg0KDQoNCg0KUk0gIwlSTSAjCVJNICMNCg0KDQoNClxzMVwNCg0KLy9hbmNoMSANCgkvL2FuY2gyDQoJCS8vYW5jaDM=",
		"documentId": "1",
		"fileExtension": "txt",
		"name": "NDA"
	}],
	"emailBlurb": "Sample text for email body",
	"emailSubject": "Please Sign",
	"envelopeIdStamping": "true",
	"recipients": {
	"signers": [{
		"name": "'"${SIGNER_NAME}"'",
		"email": "'"${SIGNER_EMAIL}"'",
		"roleName": "signer",
		"note": "",
		"routingOrder": 1,
		"status": "sent",
				"tabs": {
				"signHereTabs": [{
					"documentId": "1",
					"name": "SignHereTab",
					"pageNumber": "1",
					"recipientId": "1",
					"tabLabel": "SignHereTab",
					"xPosition": "75",
					"yPosition": "572"
				}]
			},
		"deliveryMethod": "email",
		"recipientId": "1",
	}],
	},
	"brandId": "'$brand_id'",
	"status": "Sent"
}' >> $request_data
#ds-snippet-end:eSign29Step3

# Step 4: a) Call the eSignature API
#         b) Display the JSON response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)
#ds-snippet-start:eSign29Step4
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
#ds-snippet-end:eSign29Step4
# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Creating a new envelope has failed."
	echo ""
	cat $response
	exit 0
fi
echo ""
echo "Response:"
cat $response
echo ""
# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo ""
echo "Done."
echo ""

