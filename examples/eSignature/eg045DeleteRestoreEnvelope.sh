# Delete and Undelete an Envelope
#
# This script performs two sequential operations on a Docusign envelope:
# 1. Deletes the envelope by moving it to the Recycle Bin.
# 2. Pause for User Confirmation and Get the Destination Folder Name from User.
# 3. Find the user-specified folder. If not available, use default folder.
# 4. Undeletes the envelope from the Recycle Bin to a user-specified or default folder.
#

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

# Construct your API headers
#ds-snippet-start:eSign45Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:eSign45Step2

# Check that we have an envelope id
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit 0
fi
envelope_id=`cat config/ENVELOPE_ID`

# Get Envelope ID from user or config file
echo ""
echo "Select the envelope ID to use for the delete and undelete operations."
echo ""
if [ -f config/ENVELOPE_ID ]; then
    envelope_id_from_file=$(cat config/ENVELOPE_ID)
    read -p "Use the envelope ID from 'config/ENVELOPE_ID' (${envelope_id_from_file})? (y/n): " use_existing_id
    if [[ "$use_existing_id" == "y" || "$use_existing_id" == "Y" ]]; then
        envelope_id=$envelope_id_from_file
    else
        read -p "Please enter the new envelope ID: " new_envelope_id
        envelope_id=$new_envelope_id
    fi
else
    read -p "No envelope ID found. Please enter the envelope ID: " new_envelope_id
    envelope_id=$new_envelope_id
fi

if [ -z "$envelope_id" ]; then
    echo ""
    echo "ERROR: No envelope ID was provided"
    echo ""
fi


# PART 1: Delete the Envelope

echo ""
echo "Deleting the Envelope with ID: ${envelope_id}"
echo "Sending PUT request to Docusign..."
echo "Results:"
echo ""
# Create the request body for deleting the envelope
request_body=$(mktemp)
#ds-snippet-start:eSign45Step3
printf '{
  "envelopeIds": [
    "%s"
  ]
}' "${envelope_id}" > $request_body
#ds-snippet-end:eSign45Step3  

#ds-snippet-start:eSign45Step4
curl --request PUT "${base_path}/v2.1/accounts/${account_id}/folders/recyclebin" \
    "${Headers[@]}" \
    --data-binary @${request_body}
#ds-snippet-end:eSign45Step4

echo ""
echo ""
echo "The deleted envelope is now in your Docusign Recycle Bin."
echo "You can check your web app to confirm the deletion."


# PART 2: Pause for User Confirmation and Get the Destination Folder Name from User

echo ""
read -p "Press Enter to proceed with restoring the envelope from the Recycle Bin..."

# Prompt for the destination folder name and handle spaces
read -p "Please enter the name of the folder to undelete the envelope to (e.g., 'Sent Items') or press Enter to use the default: " destination_folder_name
# Set default folder if none is provided
if [ -z "$destination_folder_name" ]; then
    destination_folder_name="Sent Items"
    echo "The undeleted item will be moved to the Sent Items folder."
fi

# PART 3: Find the Folder ID

echo "Searching for folder with name: '${destination_folder_name}'..."

# Store the API response in a variable
#ds-snippet-start:eSign45Step5
RESPONSE=$(curl --request GET \
    "${Headers[@]}" \
    "${base_path}/v2.1/accounts/${account_id}/folders")

# Find the specific folder entered and extract its folderId

folder_id=$(echo "${RESPONSE}" | grep -oi "\"name\":\"${destination_folder_name}\",\"type\":\"[^\"]*\",\"owner\":{[^\}]*},\"folderId\":\"[^\"]*\"" | sed 's/.*"folderId":"//' | sed 's/"$//')
#ds-snippet-end:eSign45Step5
if [ -z "$folder_id" ]; then
    echo "ERROR: Could not find a folder with the name '${destination_folder_name}'. Please check the spelling."
fi

echo "Found folder ID: ${folder_id} for folder name: '${destination_folder_name}'"

# PART 4: Undelete the Envelope

echo ""
echo "Restoring the Envelope from Recycle Bin to the '${destination_folder_name}' folder."
echo "Sending PUT request to Docusign..."
echo "Results:"
echo ""

#ds-snippet-start:eSign45Step6
curl --request PUT "${base_path}/v2.1/accounts/${account_id}/folders/${folder_id}" \
    "${Headers[@]}" \
    --data-raw '{
      "envelopeIds": [
        "'${envelope_id}'"
      ],
      "fromFolderId": "recyclebin"
    }'
#ds-snippet-end:eSign45Step6

echo ""
echo ""
echo "The envelope has been undeleted and is now in your '${destination_folder_name}' folder."
echo ""
