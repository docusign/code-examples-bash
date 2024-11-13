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

# Check if agreements file exists and has content
if [[ ! -s "$agreements" ]]; then
    echo "Please run Navigator example 1: List_Agreements first to get a list of agreements."
    exit 0
fi

#Display list of agreements
# Initialize an array to hold the file_names
file_names=()

# Read each line from AGREEMENTS.txt and populate file_names array
while IFS=' ' read -r id file_name; do
    file_names+=("$file_name")
done < $agreements

# Display the file_name options to the user for selection
echo "Please select an agreement:"
select chosen_name in "${file_names[@]}"; do
    if [[ -n "$chosen_name" ]]; then
        # Find the matching line and extract the corresponding id
        AGREEMENT_ID=$(grep -w "$chosen_name" "$agreements" | awk '{print $1}')
        echo "You selected: $chosen_name"
        echo "AGREEMENT_ID: $AGREEMENT_ID"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

#ds-snippet-start:Navigator2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:Navigator2Step2

# Get Agreement
#ds-snippet-start:Navigator2Step3
response=$(mktemp /tmp/response-neg-002.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/accounts/${ACCOUNT_ID}/agreements/${AGREEMENT_ID} \
    "${Headers[@]}" \
    --output ${response})
#ds-snippet-end:Navigator2Step3


if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Error: "
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
