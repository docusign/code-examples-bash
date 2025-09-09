# Delete and Restore an Envelope
#
# This script performs two sequential operations on a DocuSign envelope:
# 1. Deletes the envelope by moving it to the Recycle Bin.
# 2. Pauses for user confirmation.
# 3. Restores the envelope from the Recycle Bin to the Sent Items folder.
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
echo "Select the envelope ID to use for the delete and restore operations."
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
echo "Sending PUT request to DocuSign..."
echo "Results:"
echo ""

#ds-snippet-start:eSign45Step2
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --request PUT "${base_path}/v2.1/accounts/${account_id}/folders/recyclebin" \
    --data-raw '{
      "envelopeIds": [
        "'${envelope_id}'"
      ]
    }'
#ds-snippet-end:eSign45Step2

echo ""
echo ""
echo "The deleted envelope is now in your DocuSign Recycle Bin."
echo "You can check your web app to confirm the deletion."


# PART 2: Pause for User Confirmation

echo ""
read -p "Press Enter to proceed with restoring the envelope from the Recycle Bin..."

# PART 3: Restore the Envelope

echo ""
echo "Restoring the Envelope from Recycle Bin to the Sent Items folder."
echo "Sending PUT request to DocuSign..."
echo "Results:"
echo ""

#ds-snippet-start:eSign45Step3
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --request PUT "${base_path}/v2.1/accounts/${account_id}/folders/sentitems" \
    --data-raw '{
      "envelopeIds": [
        "'${envelope_id}'"
      ],
      "fromFolderId": "recyclebin"
    }'
#ds-snippet-end:eSign45Step3

echo ""
echo ""
echo "The envelope has been restored and is now in your DocuSign Sent Items folder."
echo ""
