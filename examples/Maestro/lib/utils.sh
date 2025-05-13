#!/bin/bash
#
# Check that we're in a bash shell

if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi


echo "This script uses the package uuidgen to create unique ids for workflow fields. If you do not already have this installed, please visit the Readme at link for installation instructions. If you are on Mac/linux, this is likely already installed."
echo "Press any key to continue"
read continue

TEMPLATE_ID=$(cat config/TEMPLATE_ID)
if [ -z "$TEMPLATE_ID" ]; then
    echo "Creating template"
    bash ./examples/eSignature/eg008CreateTemplate.sh
fi

TEMPLATE_ID=$(cat config/TEMPLATE_ID)
if [ -z "$TEMPLATE_ID" ]; then
    echo "please create a worklow before running this example"
    exit 0
fi

TEMPLATE_ID=$(cat config/TEMPLATE_ID)

echo "Creating a new workflow"

SIGNER_ID=$(uuidgen | tr 'A-Z' 'a-z')
CC_ID=$(uuidgen | tr 'A-Z' 'a-z')
TRIGGER_ID="wfTrigger"

accessToken=$(cat config/ds_access_token.txt)
accountId=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.services.docusign.net/aow-manage/v1.0"
auth_base_path="https://demo.services.docusign.net/aow-auth/v1.0"

declare -a Headers=('--header' "Authorization: Bearer ${accessToken}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")

request_data=$(mktemp /tmp/request-wf.XXXXXX)
printf \
'{
    "workflowDefinition": {
        "workflowName": "Example workflow - send invite to signer",
        "workflowDescription": "",
        "accountId": "'"${accountId}"'",
        "documentVersion": "1.0.0",
        "schemaVersion": "1.0.0",
        "participants": {
            "'"${SIGNER_ID}"'": {
                "participantRole": "Signer"
            },
            "'"${CC_ID}"'": {
                "participantRole": "CC"
            }
        },
        "trigger": {
            "name": "Get_URL",
            "type": "Http",
            "httpType": "Get",
            "id": "'"${TRIGGER_ID}"'",
            "input": {
                "metadata": {
                    "customAttributes": {}
                },
                "payload": {
                    "dacId_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "dacId",
                        "stepId": "'"${TRIGGER_ID}"'"
                    },
                    "id_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "id",
                        "stepId": "'"${TRIGGER_ID}"'"
                    },
                    "signerName_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "signerName",
                        "stepId": "'"${TRIGGER_ID}"'"
                    },
                    "signerEmail_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "signerEmail",
                        "stepId": "'"${TRIGGER_ID}"'"
                    },
                    "ccName_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "ccName",
                        "stepId": "'"${TRIGGER_ID}"'"
                    },
                    "ccEmail_'"${TRIGGER_ID}"'": {
                        "source": "step",
                        "propertyName": "ccEmail",
                        "stepId": "'"${TRIGGER_ID}"'"
                    }
                },
                "participants": {}
            },
            "output": {
                "dacId_'"${TRIGGER_ID}"'": {
                    "source": "step",
                    "propertyName": "dacId",
                    "stepId": "'"${TRIGGER_ID}"'"
                }
            },
            "type": "API"
        },
        "variables": {
            "dacId_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "dacId",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "id_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "id",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "signerName_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "signerName",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "signerEmail_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "signerEmail",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "ccName_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "ccName",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "ccEmail_'"${TRIGGER_ID}"'": {
                "source": "step",
                "propertyName": "ccEmail",
                "stepId": "'"${TRIGGER_ID}"'"
            },
            "envelopeId_step2": {
                "source": "step",
                "propertyName": "envelopeId",
                "stepId": "step2",
                "type": "String"
            },
            "combinedDocumentsBase64_step2": {
                "source": "step",
                "propertyName": "combinedDocumentsBase64",
                "stepId": "step2",
                "type": "File"
            },
            "fields.signer.text.value_step2": {
                "source": "step",
                "propertyName": "fields.signer.text.value",
                "stepId": "step2",
                "type": "String"
            }
        },
        "steps": [
            {
                "id": "step2",
                "name": "Get Signatures",
                "moduleName": "ESign",
                "configurationProgress": "Completed",
                "type": "DS-Sign",
                "config": {
                    "participantId": "'"${SIGNER_ID}"'"
                },
                "input": {
                    "isEmbeddedSign": true,
                    "documents": [
                        {
                            "type": "FromDSTemplate",
                            "eSignTemplateId": "'"${TEMPLATE_ID}"'"
                        }
                    ],
                    "emailSubject": "Please sign this document",
                    "emailBlurb": "",
                    "recipients": {
                        "signers": [
                            {
                                "defaultRecipient": "false",
                                "tabs": {
                                    "signHereTabs": [
                                        {
                                            "stampType": "signature",
                                            "name": "SignHere",
                                            "tabLabel": "Sign Here",
                                            "scaleValue": "1",
                                            "optional": "false",
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "191",
                                            "yPosition": "148",
                                            "tabId": "1",
                                            "tabType": "signhere"
                                        }
                                    ],
                                    "textTabs": [
                                        {
                                            "requireAll": "false",
                                            "value": "",
                                            "required": "false",
                                            "locked": "false",
                                            "concealValueOnDocument": "false",
                                            "disableAutoSize": "false",
                                            "tabLabel": "text",
                                            "font": "helvetica",
                                            "fontSize": "size14",
                                            "localePolicy": {},
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "153",
                                            "yPosition": "230",
                                            "width": "84",
                                            "height": "23",
                                            "tabId": "2",
                                            "tabType": "text"
                                        }
                                    ],
                                    "checkboxTabs": [
                                        {
                                            "name": "",
                                            "tabLabel": "ckAuthorization",
                                            "selected": "false",
                                            "selectedOriginal": "false",
                                            "requireInitialOnSharedChange": "false",
                                            "required": "true",
                                            "locked": "false",
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "75",
                                            "yPosition": "417",
                                            "width": "0",
                                            "height": "0",
                                            "tabId": "3",
                                            "tabType": "checkbox"
                                        },
                                        {
                                            "name": "",
                                            "tabLabel": "ckAuthentication",
                                            "selected": "false",
                                            "selectedOriginal": "false",
                                            "requireInitialOnSharedChange": "false",
                                            "required": "true",
                                            "locked": "false",
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "75",
                                            "yPosition": "447",
                                            "width": "0",
                                            "height": "0",
                                            "tabId": "4",
                                            "tabType": "checkbox"
                                        },
                                        {
                                            "name": "",
                                            "tabLabel": "ckAgreement",
                                            "selected": "false",
                                            "selectedOriginal": "false",
                                            "requireInitialOnSharedChange": "false",
                                            "required": "true",
                                            "locked": "false",
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "75",
                                            "yPosition": "478",
                                            "width": "0",
                                            "height": "0",
                                            "tabId": "5",
                                            "tabType": "checkbox"
                                        },
                                        {
                                            "name": "",
                                            "tabLabel": "ckAcknowledgement",
                                            "selected": "false",
                                            "selectedOriginal": "false",
                                            "requireInitialOnSharedChange": "false",
                                            "required": "true",
                                            "locked": "false",
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "75",
                                            "yPosition": "508",
                                            "width": "0",
                                            "height": "0",
                                            "tabId": "6",
                                            "tabType": "checkbox"
                                        }
                                    ],
                                    "radioGroupTabs": [
                                        {
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "groupName": "radio1",
                                            "radios": [
                                                {
                                                    "pageNumber": "1",
                                                    "xPosition": "142",
                                                    "yPosition": "384",
                                                    "value": "white",
                                                    "selected": "false",
                                                    "tabId": "7",
                                                    "required": "false",
                                                    "locked": "false",
                                                    "bold": "false",
                                                    "italic": "false",
                                                    "underline": "false",
                                                    "fontColor": "black",
                                                    "fontSize": "size7"
                                                },
                                                {
                                                    "pageNumber": "1",
                                                    "xPosition": "74",
                                                    "yPosition": "384",
                                                    "value": "red",
                                                    "selected": "false",
                                                    "tabId": "8",
                                                    "required": "false",
                                                    "locked": "false",
                                                    "bold": "false",
                                                    "italic": "false",
                                                    "underline": "false",
                                                    "fontColor": "black",
                                                    "fontSize": "size7"
                                                },
                                                {
                                                    "pageNumber": "1",
                                                    "xPosition": "220",
                                                    "yPosition": "384",
                                                    "value": "blue",
                                                    "selected": "false",
                                                    "tabId": "9",
                                                    "required": "false",
                                                    "locked": "false",
                                                    "bold": "false",
                                                    "italic": "false",
                                                    "underline": "false",
                                                    "fontColor": "black",
                                                    "fontSize": "size7"
                                                }
                                            ],
                                            "shared": "false",
                                            "requireInitialOnSharedChange": "false",
                                            "requireAll": "false",
                                            "tabType": "radiogroup",
                                            "value": "",
                                            "originalValue": ""
                                        }
                                    ],
                                    "listTabs": [
                                        {
                                            "listItems": [
                                                {
                                                    "text": "Red",
                                                    "value": "red",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Orange",
                                                    "value": "orange",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Yellow",
                                                    "value": "yellow",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Green",
                                                    "value": "green",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Blue",
                                                    "value": "blue",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Indigo",
                                                    "value": "indigo",
                                                    "selected": "false"
                                                },
                                                {
                                                    "text": "Violet",
                                                    "value": "violet",
                                                    "selected": "false"
                                                }
                                            ],
                                            "value": "",
                                            "originalValue": "",
                                            "required": "false",
                                            "locked": "false",
                                            "requireAll": "false",
                                            "tabLabel": "list",
                                            "font": "helvetica",
                                            "fontSize": "size14",
                                            "localePolicy": {},
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "142",
                                            "yPosition": "291",
                                            "width": "78",
                                            "height": "0",
                                            "tabId": "10",
                                            "tabType": "list"
                                        }
                                    ],
                                    "numericalTabs": [
                                        {
                                            "validationType": "currency",
                                            "value": "",
                                            "required": "false",
                                            "locked": "false",
                                            "concealValueOnDocument": "false",
                                            "disableAutoSize": "false",
                                            "tabLabel": "numericalCurrency",
                                            "font": "helvetica",
                                            "fontSize": "size14",
                                            "localePolicy": {
                                                "cultureName": "en-US",
                                                "currencyPositiveFormat": "csym_1_comma_234_comma_567_period_89",
                                                "currencyNegativeFormat": "opar_csym_1_comma_234_comma_567_period_89_cpar",
                                                "currencyCode": "usd"
                                            },
                                            "documentId": "1",
                                            "recipientId": "1",
                                            "pageNumber": "1",
                                            "xPosition": "163",
                                            "yPosition": "260",
                                            "width": "84",
                                            "height": "0",
                                            "tabId": "11",
                                            "tabType": "numerical"
                                        }
                                    ]
                                },
                                "signInEachLocation": "false",
                                "agentCanEditEmail": "false",
                                "agentCanEditName": "false",
                                "requireUploadSignature": "false",
                                "name": {
                                    "source": "step",
                                    "propertyName": "signerName",
                                    "stepId": "'"${TRIGGER_ID}"'"
                                },
                                "email": {
                                    "source": "step",
                                    "propertyName": "signerEmail",
                                    "stepId": "'"${TRIGGER_ID}"'"
                                },
                                "recipientId": "1",
                                "recipientIdGuid": "00000000-0000-0000-0000-000000000000",
                                "accessCode": "",
                                "requireIdLookup": "false",
                                "routingOrder": "1",
                                "note": "",
                                "roleName": "signer",
                                "completedCount": "0",
                                "deliveryMethod": "email",
                                "templateLocked": "false",
                                "templateRequired": "false",
                                "inheritEmailNotificationConfiguration": "false",
                                "recipientType": "signer"
                            }
                        ],
                        "carbonCopies": [
                            {
                                "agentCanEditEmail": "false",
                                "agentCanEditName": "false",
                                "name": {
                                    "source": "step",
                                    "propertyName": "ccName",
                                    "stepId": "'"${TRIGGER_ID}"'"
                                },
                                "email": {
                                    "source": "step",
                                    "propertyName": "ccEmail",
                                    "stepId": "'"${TRIGGER_ID}"'"
                                },
                                "recipientId": "2",
                                "recipientIdGuid": "00000000-0000-0000-0000-000000000000",
                                "accessCode": "",
                                "requireIdLookup": "false",
                                "routingOrder": "2",
                                "note": "",
                                "roleName": "cc",
                                "completedCount": "0",
                                "deliveryMethod": "email",
                                "templateLocked": "false",
                                "templateRequired": "false",
                                "inheritEmailNotificationConfiguration": "false",
                                "recipientType": "carboncopy"
                            }
                        ],
                        "certifiedDeliveries": []
                    }
                },
                "output": {
                    "envelopeId_step2": {
                        "source": "step",
                        "propertyName": "envelopeId",
                        "stepId": "step2",
                        "type": "String"
                    },
                    "combinedDocumentsBase64_step2": {
                        "source": "step",
                        "propertyName": "combinedDocumentsBase64",
                        "stepId": "step2",
                        "type": "File"
                    },
                    "fields.signer.text.value_step2": {
                        "source": "step",
                        "propertyName": "fields.signer.text.value",
                        "stepId": "step2",
                        "type": "String"
                    }
                }
            },
            {
                "id": "step3",
                "name": "Show a Confirmation Screen",
                "moduleName": "ShowConfirmationScreen",
                "configurationProgress": "Completed",
                "type": "DS-ShowScreenStep",
                "config": {
                    "participantId": "'"${SIGNER_ID}"'"
                },
                "input": {
                    "httpType": "Post",
                    "payload": {
                        "participantId": "'"${SIGNER_ID}"'",
                        "confirmationMessage": {
                            "title": "Tasks complete",
                            "description": "You have completed all your workflow tasks."
                        }
                    }
                },
                "output": {},
                "triggerType": "API"
            }
        ]
    }
}' >$request_data

response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" --request POST "${base_path}/management/accounts/${accountId}/workflowDefinitions" \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})

# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to create a new workflow"
    echo ""
    cat $response
    exit 0
fi

workflow_id=`cat $response | grep workflowDefinitionId | sed 's/.*\"workflowDefinitionId\":\"//' | sed 's/\",.*//'`
redirect_url="http://localhost:8080"

#Publish workflow
response=$(mktemp /tmp/response-wftmp.XXXXXX)
published="false"
while [ $published == "false" ];
do
    Status=$(curl -s -w "%{http_code}\n" --request POST "${base_path}/management/accounts/${accountId}/workflowDefinitions/${workflow_id}/publish?isPreRunCheck=true" \
        "${Headers[@]}" \
        --output ${response} )

    # If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
    if [[ "$Status" -gt "201" ]]; then
        message=`cat $response | grep message | sed 's/.*\"message\":\"//' | sed 's/\".*//'`
        if [[ "$message" == "Consent required" ]]; then
            consent_url=`cat $response | grep consentUrl | sed 's/.*\"consentUrl\":\"//' | sed 's/\".*//'`
            echo ""
            echo "Please grant consent at the following url to publish this workflow: ${consent_url}&host=${redirect_url}"
            read -p "Press any key to continue"
        else
            echo $message
            exit 0
        fi
    else
        published="true"
        echo $workflow_id >config/WORKFLOW_ID
        echo "Successfully created and published workflow ${workflow_id}, ID saved to config/WORKFLOW_ID"
    fi
done

# Remove the temporary files
rm "$request_data"
rm "$response"
