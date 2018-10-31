# Download a document from an envelope
# This script uses the envelope_id stored in ../envelope_id.
# The envelope_id file is created by example eg002SigningViaEmail.sh or
# can be manually created.

output_file="envelope_document."

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope id
if [ ! -f ../envelope_id ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit -1
fi
envelope_id=`cat ../envelope_id`

doc_choice=1
output_file_extension=pdf
echo ""
PS3='Select a document or document set to download: '
options=("Documents combined together" "ZIP file" "Document 1" "Document 2" "Document 3")
select opt in "${options[@]}"
do
    case $opt in
        "Documents combined together")
            doc_choice=combined
            break
            ;;
        "ZIP file")
            doc_choice=archive
            output_file_extension=zip
            break
            ;;
        "Document 1")
            doc_choice=1
            break
            ;;
        "Document 2")
            doc_choice=2
            break
            ;;
        "Document 3")
            doc_choice=3
            break
            ;;
    esac
done

echo ""
echo "Sending the EnvelopeDocuments::get request to DocuSign..."
echo ""

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2/accounts/{ACCOUNT_ID}/envelopes/${envelope_id}/documents/${doc_choice} \
     --output ${output_file}${output_file_extension}

echo ""
echo "The document(s) are stored in file ${output_file}${output_file_extension}"
echo ""
echo "Done."
echo ""

