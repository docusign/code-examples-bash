# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.com/v1"

request_data=$(mktemp /tmp/request-nav-003.XXXXXX)
response=$(mktemp /tmp/response-nav-003.XXXXXX)

#ds-snippet-start:Navigator3Step2
printf \
'{
    "job_name": "Example bulk upload job",
    "expected_number_of_docs": 5,
    "language": "en-US"
}' >> $request_data

curl --request POST ${base_path}/accounts/${account_id}/upload/jobs \
     --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Accept: application/json" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --output $response

# Extract job ID and upload URLs for each document
job_id=$(cat "$response" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
upload_urls=$(cat $response | grep -o '"upload_document":"[^"]*' | cut -d'"' -f4)
#ds-snippet-end:Navigator3Step2

echo "Created upload job with ID: $job_id"

read -p "Press Enter to upload documents for this job"

echo "Uploading documents..."
echo ""

#ds-snippet-start:Navigator3Step3
# Array of demo documents to upload
declare -a demo_files=(
    "demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx"
    "demo_documents/World_Wide_Corp_lorem.pdf"
    "demo_documents/doc_1.html"
    "demo_documents/Welcome.txt"
    "demo_documents/Id.jpg"
)

# Convert to array (cross-platform: works on macOS and Linux)
upload_urls_array=()
while IFS= read -r url; do
    upload_urls_array+=("$url")
done <<<"$upload_urls"

# Upload each file
for i in "${!demo_files[@]}"; do
    file_path="${demo_files[$i]}"
    upload_url="${upload_urls_array[$i]}"
    
    # Extract filename from path
    filename=$(basename "$file_path")
    
    if [[ ! -f "$file_path" ]]; then
        echo "Skipping $filename - file not found: $file_path"
        continue
    fi
    
    if [[ -z "$upload_url" ]]; then
        echo "Skipping $filename - no upload URL found"
        continue
    fi

    case "$filename" in
        *.docx)
            content_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            ;;
        *.pdf)
            content_type="application/pdf"
            ;;
        *.html)
            content_type="text/html"
            ;;
        *.txt)
            content_type="text/plain"
            ;;
        *.jpg|*.jpeg)
            content_type="image/jpeg"
            ;;
        *)
            content_type="application/octet-stream"
            ;;
    esac
    
    echo "Uploading $filename..."
    

    # Make PUT request with binary file content and required headers.
    curl --request PUT "$upload_url" \
         --header "x-ms-blob-type: BlockBlob" \
         --header "x-ms-meta-filename: ${filename}" \
         --header "Content-Type: ${content_type}" \
         --data-binary @"$file_path"
done
#ds-snippet-end:Navigator3Step3

echo ""
read -p "The documents have been uploaded. Press Enter to update the job status."

#ds-snippet-start:Navigator3Step4
curl --request POST "${base_path}/accounts/${account_id}/upload/jobs/${job_id}/actions/complete" \
     --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Accept: application/json" \
     --header "Content-Type: application/json" \
     --output "$response"
#ds-snippet-end:Navigator3Step4

echo ""
echo "Bulk upload job has been completed. Response:"
echo ""
cat "$response"
echo ""

rm -f "$response"
rm -f "$request_data"

echo ""
echo "Done."
echo ""
