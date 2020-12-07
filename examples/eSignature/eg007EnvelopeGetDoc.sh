# Download a document from an envelope
# This script uses the envelope_id stored in ../envelope_id.
# The envelope_id file is created by example eg002SigningViaEmail.sh or
# can be manually created.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Configuration
# 1. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 2. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)
#
output_file="envelope_document."

base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope id
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit 0
fi
envelope_id=`cat config/ENVELOPE_ID`

doc_choice=1
output_file_extension=pdf
echo ""
PS3='Select a document or document set to download: '
options=("Document 1" "Document 2" "Document 3" "Certificate of Completion" "Documents combined together" "ZIP file" )
select opt in "${options[@]}"
do
    case $opt in
        "Certificate of Completion")
            doc_choice=certificate
            break
            ;;
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

# ***DS.snippet.0.start
curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/documents/${doc_choice} \
     --output ${output_file}${output_file_extension}
# ***DS.snippet.0.end

echo ""
echo "The document(s) are stored in file ${output_file}${output_file_extension}"
echo ""
echo "Done."
echo ""

