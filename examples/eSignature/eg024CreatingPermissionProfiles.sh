# Create Permission Profile

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



read -p "Please enter a new permission profile name [Bash_Perms_{date}]: " PROFILE_NAME
PROFILE_NAME=${PROFILE_NAME:-"Bash_Perms_"$(date +%Y-%m-%d-%H:%M)}
export PROFILE_NAME


# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct the request body for your pemisison profile
# Create a temporary file to store the request body
base_path="https://demo.docusign.net/restapi"
request_data=$(mktemp /tmp/request-perm-001.XXXXXX)
printf \
'{
      "permissionProfileName": "'"${PROFILE_NAME}"'",
      "settings" : { 
        "useNewDocuSignExperienceInterface":0,
        "allowBulkSending":"true",
        "allowEnvelopeSending":"true",
        "allowSignerAttachments":"true",
        "allowTaggingInSendAndCorrect":"true",
        "allowWetSigningOverride":"true",
        "allowedAddressBookAccess":"personalAndShared",
        "allowedTemplateAccess":"share",
        "enableRecipientViewingNotifications":"true",
        "enableSequentialSigningInterface":"true",
        "receiveCompletedSelfSignedDocumentsAsEmailLinks":"false",
        "signingUiVersion":"v2",
        "useNewSendingInterface":"true",
        "allowApiAccess":"true",
        "allowApiAccessToAccount":"true",
        "allowApiSendingOnBehalfOfOthers":"true",
        "allowApiSequentialSigning":"true",
        "enableApiRequestLogging":"true",
        "allowDocuSignDesktopClient":"false",
        "allowSendersToSetRecipientEmailLanguage":"true",
        "allowVaulting":"false",
        "allowedToBeEnvelopeTransferRecipient":"true",
        "enableTransactionPointIntegration":"false",
        "powerFormRole":"admin",
        "vaultingMode":"none"
      }
}' >> $request_data

# Step 4: a) Call the eSignature API
#         b) Display the JSON response    
# Create a temporary file to store the response
response=$(mktemp /tmp/response-perm.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/permission_profiles \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Unable to create a new permissions profile."
	echo ""
	cat $response
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""


# Retrieve the profile ID from the API response.
profileID=`cat $response | grep permissionProfileId | sed 's/.*\"permissionProfileId\":\"//' | sed 's/\",.*//'`
# Save the envelope id for use by other scripts
echo "Permission Profile ID: ${profileID}"
echo ${profileID} > config/PROFILE_ID
echo ${PROFILE_NAME} > config/PROFILE_NAME

# Remove the temporary files
rm "$request_data"
rm "$response"
echo ""
echo ""
echo "Done."
echo ""

