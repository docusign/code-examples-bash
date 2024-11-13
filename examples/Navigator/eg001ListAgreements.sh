# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"
agreements="config/AGREEMENTS.txt"

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.com/v1"

#ds-snippet-start:Navigator1Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:Navigator1Step2

# List agreements
#ds-snippet-start:Navigator1Step3
response=$(mktemp /tmp/response-cw.XXXXXX)
Status=$(curl -w '%{http_code}' -i --ssl-no-revoke --request GET ${base_path}/accounts/${ACCOUNT_ID}/agreements \
    "${Headers[@]}" \
    --output ${response})
#ds-snippet-end:Navigator1Step3

if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Listing agreements..."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Extract id and file_name from each data object in the $response file
> "$agreements"  # Clear the output file at the beginning
capture_id=false

# Process each line in the $response file
while read -r line; do
    # Check for "id" and capture it if found
    case "$line" in
        *'"id"':*)
            # Extract the id value
            id="${line#*\"id\": \"}"
            id="${id%%\",*}"
            capture_id=true
            ;;
        *'"file_name"':*)
            if $capture_id; then
                # Extract the file_name value
                file_name="${line#*\"file_name\": \"}"
                file_name="${file_name%%\"*}"

                # Write id and file_name to the output file
                echo "$id $file_name" >> "$agreements"

                # Reset the capture flag
                capture_id=false
            fi
            ;;
    esac
done < "$response"

# Remove the temporary files
rm "$response"
