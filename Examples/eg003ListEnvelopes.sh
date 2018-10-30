# List envelopes and their status
# List changes for the last 10 days

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# temp files:
request_data=$(mktemp /tmp/request.XXXXXX)

echo ""
echo "Sending the list envelope status request to DocuSign..."
echo "Results:"
echo ""

# Calculate the from_date query parameter and use the
# ISO 8601 format.
# Example:
# from_date=2018-09-30T07:43:12+03:00
# For a Mac, 10 days in the past:
from_date=`date -v -10d '+%Y-%m-%dT%H:%M:%S%z'`
# Other Linux systems may be different

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --get \
     --data-urlencode 'from_date=${from_date}' \
     --request GET https://demo.docusign.net/restapi/v2/accounts/{ACCOUNT_ID}/envelopes


# $ curl -X PUT -G 'http://example.com/resource/1' --data-urlencode 'param1=value 1' --data-urlencode param2=value2



# cleanup
rm "$request_data"
rm "$doc1_base64"
rm "$doc2_base64"
rm "$doc3_base64"

echo ""
echo ""
echo "Done."
echo ""

