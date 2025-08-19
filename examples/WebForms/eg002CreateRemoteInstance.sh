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
echo "Go to your Docusign account to create the Web Form. Go to 'Templates' in your developer account, select 'Start,' select 'Web Forms,' and choose 'Upload Web Form.' Upload the JSON config file 'web-form-config.json' found under the demo_documents folder of this project. You will need to activate the web form before proceeding. Press the enter key after doing so."
read choice
#ds-snippet-start:WebForms2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:WebForms2Step2

# List web forms in account that match the name of the web form we just created
#ds-snippet-start:WebForms2Step3
response=$(mktemp /tmp/response-cw.XXXXXX)
Status=$(curl -w '%{http_code}' --request GET ${base_path}/accounts/${ACCOUNT_ID}/forms?search=Web%20Form%20Example%20Template \
    "${Headers[@]}" \
    --output ${response})

FORM_ID=$(cat $response | sed 's/,/\n/g' | grep id | sed 's/.*\"id\":\"//g' | sed 's/\".*//g')
#ds-snippet-end:WebForms2Step3

request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
#ds-snippet-start:WebForms2Step4
printf \
'{
    "clientUserId": "1234-5678-abcd-ijkl",
    "sendOption": "now",
    "formValues": {
        "PhoneNumber": "555-555-5555",
        "Yes": ["Yes"],
        "Company": "Tally",
        "JobTitle": "Programmer Writer"
    },
    "recipients": [
        {
            "roleName": "signer",
            "routingOrder": "1",
            "name": "'"${SIGNER_NAME}"'",
            "email": "'"${SIGNER_EMAIL}"'"
        }
    ]
}' >$request_data
#ds-snippet-end:WebForms2Step4

response=$(mktemp /tmp/response-cw.XXXXXX)
#ds-snippet-start:WebForms2Step5
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/accounts/${ACCOUNT_ID}/forms/${FORM_ID}/instances \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})
#ds-snippet-end:WebForms2Step5

if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Creating a new instance of the web form..."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""