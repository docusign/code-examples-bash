# Creating a brand

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

read -p "Please enter a new brand name [Sample Bash Corp. {date}]: " BRAND
BRAND=${BRAND:-"Sample Bash Corp. "$(date +%Y-%m-%d-%H:%M)}
export BRAND



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct the request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
'{

    "brandName": "'"${BRAND}"'",
    "defaultBrandLanguage": "en"

}' >> $request_data

# Step 4: a) Call the eSignature API
#         b) Display the JSON response    
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/brands \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
     
# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Creating a new brand has failed."
	echo ""
	cat $response
	exit 0
fi


# Retrieve the profile ID from the API response.
brandId=`cat $response | grep brandId | sed 's/.*\"brandId\":\"//' | sed 's/\",.*//'`
# Save the envelope id for use by other scripts
echo "brand Id: ${brandId}"
echo ${brandId} > config/BRAND_ID


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

