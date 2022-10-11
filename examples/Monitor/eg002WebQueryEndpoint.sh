# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 end

account_id=$(cat config/API_ACCOUNT_ID)

read -p "Please enter the beginning date after which you want to query results as YYYY-MM-DD: " INPUT_DATE
TIME=" 00:00:00 -0800"
# Add time and date together for proper formatting
BEGIN_TIME="$INPUT_DATE$TIME"

read -p "Please enter the ending date before which you want to query results as YYYY-MM-DD: " END_INPUT_DATE
# Add time and date together for proper formatting
END_TIME="$END_INPUT_DATE$TIME"

account_id=$(cat config/API_ACCOUNT_ID)

# Step 3 start

# Filter parameters
request_data=$(mktemp /tmp/filter.XXXXXX)

printf \
'{
  "filters": [
    {
      "FilterName": "Time",
      "BeginTime": "'"${BEGIN_TIME}"'",
      "EndTime": "'"${END_TIME}"'"
    },
	{
	  "FilterName": "Has",
	  "ColumnName": "AccountId",
	  "Value": "'"${account_id}"'"
	}
  ],
  "aggregations": [
    {
      "aggregationName": "Raw",
      "limit": "100",
      "orderby": [
        "Timestamp, desc"
      ]
    }
  ]
}' >> $request_data

# Step 3 end

# Step 4 start
# Create a temporary file to store the response
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST "https://lens-d.docusign.net/api/v2.0/datasets/monitor/web_query" \
     "${Headers[@]}" \
	 --data-binary @${request_data} \
     --output ${response})

# Step 4 end

# If the Status code returned is greater than 201 (OK / Accepted), display an error message
# along with the API response
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "You do not have Monitor enabled for your account, follow https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/ to get it enabled."
	echo ""
	exit 1
fi
echo ""
cat $response
# Remove the temporary file
rm "$response"
echo ""
echo ""
echo "Done."
echo ""
