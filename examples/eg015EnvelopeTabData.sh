# Retreive Envelope Tab Data

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
oAuthAccessToken="{ACCESS_TOKEN}"

# Set up variables for full code example
# Note: Substitute these values with your own
APIAccountId="{ACCOUNT_ID}"

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope ID
if [ ! -f ../ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg001EmbeddedSigning.sh"
    echo ""
    exit -1
fi
envelope_id=`cat ../ENVELOPE_ID`

#Step 2: Create your authorization headers

declare -a Headers=('--header' "Authorization: Bearer ${oAuthAccessToken}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: a) Make a GET call to the form_data endpoint to retrieve your envelope tab values
#         b) Display the JSON response 

response=$(mktemp /tmp/response-rst.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request GET https://demo.docusign.net/restapi/v2/accounts/${APIAccountId}/envelopes/${envelopeId}/form_data \
     "${Headers[@]}" \
     --output ${response})

if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Retrieving envelope form data has failed."
	echo ""
	cat $response
	exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$response"