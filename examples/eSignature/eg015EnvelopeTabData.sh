# Retreive Envelope Tab Data

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

# Check that we have an envelope ID
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg001EmbeddedSigning.sh"
    echo ""
    exit 0
fi
envelope_id=`cat config/ENVELOPE_ID`

#Step 2: Create your authorization headers

declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: a) Make a GET call to the form_data endpoint to retrieve your envelope tab values
#         b) Display the JSON response 

response=$(mktemp /tmp/response-rst.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/form_data \
     "${Headers[@]}" \
     --output ${response})

if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Retrieving envelope form data has failed."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"
