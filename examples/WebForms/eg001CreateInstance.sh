# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://apps-d.docusign.com/api/webforms/v1.1"

# Create template for the Web Form from the API
bash ./examples/WebForms/lib/createWebFormTemplate.sh

TEMPLATE_ID=$(cat config/WEB_FORM_TEMPLATE_ID)

web_form_config=$(cat demo_documents/web-form-config.json)
result=$(echo "$web_form_config" | sed "s/template-id/$TEMPLATE_ID/g")
echo $result > demo_documents/web-form-config.json


echo "" 
echo "Go to your DocuSign account to create the Web Form. Go to 'Forms' in your developer account, select 'New,' and choose 'Upload web form.' Upload the JSON config file 'web-form-config.json' found under the demo_documents folder of this project. You will need to activate the web form before proceeding. Press 1 to continue after doing so."
read choice
#ds-snippet-start:WebForms1Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:WebForms1Step2

# List web forms in account that match the name of the web form we just created
#ds-snippet-start:WebForms1Step3
response=$(mktemp /tmp/response-cw.XXXXXX)
Status=$(curl -w '%{http_code}' --request GET ${base_path}/accounts/${ACCOUNT_ID}/forms?search=Web%20Form%20Example%20Template \
    "${Headers[@]}" \
    --output ${response})

FORM_ID=$(cat $response | sed 's/,/\n/g' | grep id | sed 's/.*\"id\":\"//g' | sed 's/\".*//g')
#ds-snippet-end:WebForms1Step3

request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
#ds-snippet-start:WebForms1Step4
printf \
'{
    "clientUserId": "1234-5678-abcd-ijkl",
    "formValues": {
        "PhoneNumber": "555-555-5555",
        "Yes": ["Yes"],
        "Company": "Tally",
        "JobTitle": "Programmer Writer"
    },
    "expirationOffset": 3600
}' >$request_data
#ds-snippet-end:WebForms1Step4

response=$(mktemp /tmp/response-cw.XXXXXX)
#ds-snippet-start:WebForms1Step5
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/accounts/${ACCOUNT_ID}/forms/${FORM_ID}/instances \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:WebForms1Step5

if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Creating a new instance."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

FORM_URL=$(cat $response | sed 's/,/\n/g' | grep formUrl | sed 's/.*\"formUrl\":\"//g' | sed 's/\".*//g')
INSTANCE_TOKEN=$(cat $response | sed 's/,/\n/g' | grep instanceToken | sed 's/.*\"instanceToken\":\"//g' | sed 's/\".*//g')

host_url="http://localhost:8080"
if which xdg-open &> /dev/null  ; then
  xdg-open $host_url
elif which open &> /dev/null    ; then
  open $host_url
elif which start &> /dev/null   ; then
  start $host_url
fi
php ./examples/WebForms/lib/startServerForWebForms.php "$INTEGRATION_KEY_AUTH_CODE" "$FORM_URL" "$INSTANCE_TOKEN"

# Remove the temporary files
rm "$request_data"
rm "$response"
