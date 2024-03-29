# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)

# Set up variables for full code example
account_id=$(cat config/API_ACCOUNT_ID)
idv_envelope_id=$(cat config/IDV_ENVELOPE_ID)

if [ -z "$idv_envelope_id" ]; then
  echo "An IDV Envelope ID is needed. Run eSignature example 23 'Signing via Email with IDV Authentication' and complete IDV before running this code example."
  exit 1
fi

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
    '--header' "Accept: application/json, text/plain, */*" \
    '--header' "Content-Type: application/json;charset=UTF-8")

# Retrieve recipient data
#ds-snippet-start:IDEvidence2Step2
uri="https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes/${idv_envelope_id}/recipients"
response=$(mktemp /tmp/response.XXXXXX)

echo "Retrieving recipient data"

status=$(curl -s -w "%{http_code}" --request GET "${uri}" \
	"${Headers[@]}" \
	--output ${response})
#ds-snippet-end

# If the status code returned a response greater than 201, display an error message
if [[ "$status" -gt "201" ]]; then
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response:"
echo ""

# Obtain the recipient ID GUID from the API response
recipientIdGuid=$(cat $response | grep -o '"recipientIdGuid":"[^"]*' | sed 's/"recipientIdGuid":"//')
echo "recipientIdGuid: $recipientIdGuid"
echo ""

# Save the Recipient ID Guid for use by other scripts
echo $recipientIdGuid >config/RECIPIENT_ID_GUID

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
    '--header' "Accept: application/json, text/plain, */*" \
    '--header' "Content-Length: 0" \
    '--header' "Content-Type: application/json;charset=UTF-8")

# Obtain identity proof token (resource token)
#ds-snippet-start:IDEvidence2Step3
uri="https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes/${idv_envelope_id}/recipients/${recipientIdGuid}/identity_proof_token"
response=$(mktemp /tmp/response.XXXXXX)

echo "Attempting to retrieve your identity proof token"

status=$(curl -s -w "%{http_code}" --request POST "${uri}" \
	"${Headers[@]}" \
	--output ${response})
#ds-snippet-end

# If the status code returned a response greater than 201, display an error message
if [[ "$status" -gt "201" ]]; then
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response:"

#Obtain the resourceToken from the API response
resourceToken=$(cat $response | grep -o '"resourceToken":"[^"]*' | sed 's/"resourceToken":"//')

echo ""
echo "resourceToken: $resourceToken"
echo ""

# Save the Resource Token for use by other scripts
echo $resourceToken >config/RESOURCE_TOKEN

# Construct your API headers
#ds-snippet-start:IDEvidence2Step4
declare -a Headers=('--header' "Authorization: Bearer ${resourceToken}" \
    '--header' "Accept: application/json, text/plain, */*" \
    '--header' "Content-Type: application/json;charset=UTF-8")
#ds-snippet-end

# Obtain identity proof token (resource token)
#ds-snippet-start:IDEvidence2Step5
uri="https://proof-d.docusign.net/api/v1/events/person/${recipientIdGuid}.json"
response=$(mktemp /tmp/response.XXXXXX)

echo "Retrieving recipient data"

status=$(curl -s -w "%{http_code}" --request GET "${uri}" \
	"${Headers[@]}" \
	--output ${response})
#ds-snippet-end

# If the status code returned a response greater than 201, display an error message
if [[ "$status" -gt "201" ]]; then
    echo ""
    cat $response
    exit 0
fi

# Obtain the Event List from the API response
events=`cat $response | grep events | sed 's/.*\"events\":\"//' | sed 's/\",.*//'`
echo ""
echo "Response:"
cat $response
echo ""

copy_of_id_front=$(cat $response | grep -o '"copy_of_id_front":"[^"]*' | sed 's/"copy_of_id_front":"//')

echo ""
echo "copy_of_id_front: $copy_of_id_front"
echo ""

# Save the copy_of_id_front URL for use by other scripts
echo $copy_of_id_front >config/COPY_OF_ID_FRONT_URL

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${resourceToken}" \
    '--header' "Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*" \
    '--header' "Content-Type: image/jpg")

# Return a base-64 image of the front of the photo ID
echo "Retrieving recipient data"
response=$(mktemp /tmp/response.XXXXXX)

#ds-snippet-start:IDEvidence2Step6
curl --request GET "${copy_of_id_front}" \
	"${Headers[@]}" \
	--output ${response}
#ds-snippet-end

echo $(cat $response) >id_front_base64_image.txt
echo ""
echo "Response: Saved to .\id_front_base64_image.txt"

# Remove the temporary files
rm "$response"

echo ""
echo "Done."
echo ""
