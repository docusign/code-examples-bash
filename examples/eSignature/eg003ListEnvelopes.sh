# List envelopes and their status
# List changes for the last 10 days

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


echo ""
echo "Sending the list envelope status request to DocuSign..."
echo "Results:"
echo ""

#ds-snippet-start:eSign3Step2
# Calculate the from_date query parameter and use the ISO 8601 format.
# Example:
# from_date=2018-09-30T07:43:12+03:00
# For a Mac, 10 days in the past:
if date -v -10d &> /dev/null ; then
    # Mac
    from_date=`date -v -10d '+%Y-%m-%dT%H:%M:%S%z'`
else
    # Not a Mac
    from_date=`date --date='-10 days' '+%Y-%m-%dT%H:%M:%S%z'`
fi

curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --get \
     --data-urlencode "from_date=${from_date}" \
     --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes
#ds-snippet-end:eSign3Step2

echo ""
echo ""
echo "Done."
echo ""

