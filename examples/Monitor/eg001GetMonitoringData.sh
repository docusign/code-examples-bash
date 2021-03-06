# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 end


# First call the endpoint with no cursor to get the first records. 
# After each call, save the cursor and use it to make the next 
# call from the point where the previous one left off when iterating through
# the monitoring records

# Step 3 start
complete=false
cursorValue=""
iterations=0

while [ $complete == false ]; do
((iterations=iterations+1))
# Create a temporary file to store the response
response=$(mktemp /tmp/response-bs.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET "https://lens-d.docusign.net/api/v2.0/datasets/monitor/stream?cursor=${cursorValue}&limit=2000" \
     "${Headers[@]}" \
     --output ${response})
# If the Status code returned is greater than 201 (OK / Accepted), display an error message
# along with the API response
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "An error was returned."
	echo ""
	cat $response
	exit 1
fi
# Display the data
echo ""
echo "Increment:"
echo $iterations
echo "Response:"
cat $response
echo ""
# Get the endCursor value from the response. This lets you resume
# getting records from the spot where this call left off
endCursorValue=`cat $response | grep endCursor | sed 's/.*\"endCursor\":\"//' | sed 's/\",.*//'`
echo "endCursorValue is:"
echo $endCursorValue
echo "cursorValue is:"
echo $cursorValue
echo ""
# If the endCursor from the response is the same as the one that you already have, 
# it means that you have reached the end of the records
if [ "$endCursorValue" == "$cursorValue" ] ; then
    echo 'After getting records, the cursor values are the same. This indicates that you have reached the end of your available records.'
	complete=$((true))
	else
	echo 'Updating the cursor value of ' ${cursorValue} ' to the new value of ' ${endCursorValue}
	cursorValue="${endCursorValue}"
sleep 5
fi
# Step 3 end
echo ""
# Remove the temporary file
rm "$response"
done
echo ""
echo ""
echo "Done."
echo ""
