#!/bin/bash
# Create a Workspace with an existing brand (Workspaces API only)
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

# Set the Workspace API base path
base_path="https://api-d.docusign.com/v1"

request_data=$(mktemp /tmp/request-wseg-001.XXXXXX)
response=$(mktemp /tmp/response-wseg-001.XXXXXX)

# Step 2: Retrieve brand_id from config
#ds-snippet-start:Workspaces4Step2
if [[ ! -s config/BRAND_ID ]]; then
  echo "No brand_id found. Attempting to run eg028CreatingABrand.sh..."
  if [[ -x ./examples/eSignature/eg028CreatingABrand.sh ]]; then
    bash ./examples/eSignature/eg028CreatingABrand.sh
  else
    echo "eg028CreatingABrand.sh not found or not executable."
    echo "Please run the eSignature Create a Brand example first."
    exit 1
  fi
fi

# Re-check after attempt
if [[ ! -s config/BRAND_ID ]]; then
  echo "Brand creation did not produce a brand_id. Please create a brand first."
  exit 1
fi
brand_id=$(cat config/BRAND_ID)
#ds-snippet-end:Workspaces4Step2

# Step 3: Construct your API headers
#ds-snippet-start:Workspaces4Step3
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Workspaces4Step3

# Step 4: Construct the workspace definition
#ds-snippet-start:Workspaces4Step4
printf \
'{
    "name" : "Example workspace",
    "brand_id" : "'"${brand_id}"'"
}' >> $request_data
#ds-snippet-end:Workspaces4Step4

# Step 5: Call the Workspaces API
#ds-snippet-start:Workspaces4Step5
Status=$(curl -s -w "%{http_code}\n" -i \
     --request POST ${base_path}/accounts/${account_id}/workspaces \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
#ds-snippet-end:Workspaces4Step5

if [[ "$Status" -gt "201" ]] ; then
  echo ""
  echo "Failed to create Workspace."
  echo ""
  cat $response
  rm "$response"
  rm "$request_data"
  exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Pull out the workspace ID and save it
workspace_id=`cat $response | grep workspace_id | sed 's/.*\"workspace_id\":\"//' | sed 's/".*//'`
echo "Workspace created! ID: ${workspace_id}"
echo "Brand used: ${brand_id}"
echo ${workspace_id} > config/WORKSPACE_ID

rm "$response"
rm "$request_data"
