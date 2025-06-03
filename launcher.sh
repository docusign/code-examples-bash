#!/bin/bash
set -e

api_version=""

if [ ! -f "config/settings.txt" ]; then
    echo "Error: "
    echo "First copy the file 'config/settings.example.txt' to 'config/settings.txt'."
    echo "Next, fill in your API credentials, Signer name and email to continue."
    echo ""
    exit 1
fi

if [ -f "config/settings.txt" ]; then
    . config/settings.txt
fi

function isCFR() {
    response=$(mktemp /tmp/response-eg-001.XXXXXX)
    ACCOUNT_ID="$(cat config/API_ACCOUNT_ID)"
    ACCESS_TOKEN=$(cat config/ds_access_token.txt)

    curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
         --header "Content-Type: application/json" \
         --request GET https://demo.docusign.net/restapi/v2.1/accounts/${ACCOUNT_ID}/ \
         --output ${response}

    ACCOUNT_INFO=`cat $response`
    if [[ $ACCOUNT_INFO =~ "\"status21CFRPart11\":\"enabled\"" ]]; then
        CFR_STATUS="enabled"
    fi
    export CFR_STATUS

}

function resetToken() {
    rm -f config/ds_access_token* || true
}

function choose_language(){
    echo ""
    api_version=$1
    PS3='Choose an OAuth Strategy: '
    select LANGUAGE in \
        "PHP" \
        "Python"; do
        case "$LANGUAGE" in

        \
        PHP)
            php ./OAuth/jwt.php "$api_version"
            continu $api_version
            ;;

        Python)
        # Check stderr and stdout for either a python3 version number or "not found"
        if [[ $(python3 --version 2>&1) == *"not found"* ]]; then
            # If no python3, check stderr and stdout for a python version number or "not found"
            if [[ $(python --version 2>&1) != *"not found"* ]]; then
                # Didn't get a "not found" error so run python
                python ./OAuth/jwt_auth.py "$api_version"
            else
                echo "Either python or python3 must be installed to use this option."
                exit 1
            fi
        else
            # Didn't get a "not found" error so run python3
            python3 ./OAuth/jwt_auth.py "$api_version"
        fi
            continu $api_version
        esac
    done
}

# Choose an OAuth Strategy
function login() {
    echo ""
    api_version=$1
    PS3='Choose an OAuth Strategy: '
    select METHOD in \
        "Use_Authorization_Code_Grant" \
        "Use_JSON_Web_Token" \
        "Exit"; do
        case "$METHOD" in

        \
            Use_Authorization_Code_Grant)
            php ./OAuth/code_grant.php "$api_version"
            continu $api_version
            ;;

        Use_JSON_Web_Token)
            choose_language "$api_version"
            ;;

        Exit)
            exit 0
            ;;
        esac
    done

    mv ds_access_token.txt $token_file_name

    account_id=$(cat config/API_ACCOUNT_ID)
    ACCESS_TOKEN=$(cat $token_file_name)

    export ACCOUNT_ID
    export ACCESS_TOKEN

}

# The Monitor API currently only supports JWT (JSON Web Token)
function monitor-login() {
    echo ""
    api_version=$1
    PS3='Authenticate using JWT: '
    select METHOD in \
        "Use_JSON_Web_Token" \
        "Exit"; do
        case "$METHOD" in

        \
        Use_JSON_Web_Token)
            choose_language "$api_version"
            continu $api_version
            ;;

        Exit)
            exit 0
            ;;
        esac
    done

    mv ds_access_token.txt $token_file_name

    account_id=$(cat config/API_ACCOUNT_ID)
    ACCESS_TOKEN=$(cat $token_file_name)

    export ACCOUNT_ID
    export ACCESS_TOKEN
}

# Choose an API
function choices() {
    if [[ $QUICKSTART == *"true"* ]]; then
        if [[ $1 != "pick_api" ]]; then
            echo ""
            echo "Quickstart Enabled, please wait"
            echo ""

            php ./OAuth/code_grant.php "eSignature"
            isCFR
            if [[ $CFR_STATUS == *"enabled"* ]]; then
                bash ./examples/eSignature/eg041EmbeddedSigningCFR.sh
                startCFRSignature
            else
                bash ./eg001EmbeddedSigning.sh
                startSignature
            fi

            mv ds_access_token.txt $token_file_name

            ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
            ACCESS_TOKEN=$(cat $token_file_name)

            export ACCOUNT_ID
            export ACCESS_TOKEN
        fi
    fi

    echo ""
    echo "Choose an API"
    PS3='Please make a selection: '
    select METHOD in \
        "eSignature" \
        "Rooms" \
        "Click" \
        "Monitor" \
        "Admin" \
        "ID_Evidence" \
        "Notary" \
        "WebForms" \
        "Maestro" \
        "Navigator (beta)" \
        "Connected_Fields" \
        "Workspaces" \
        "Exit"; do
        case "$METHOD" in

        eSignature)
            api_version="eSignature"
            login $api_version
            ;;

        Rooms)
            api_version="Rooms"
            login $api_version
            startRooms
            ;;

        Click)
            api_version="Click"
            login $api_version
            startClick
            ;;

        Monitor)
            api_version="Monitor"
            monitor-login $api_version
            startMonitor
            ;;

        Admin)
            api_version="Admin"
            login $api_version
            startAdmin
            ;;

        ID_Evidence)
            api_version="idEvidence"
            login $api_version
            startIdEvidence
            ;;

        Notary)
            api_version="Notary"
            login $api_version
            startNotary
            ;;

        WebForms)
            api_version="WebForms"
            login $api_version
            startWebForms
            ;;

        Maestro)
            api_version="Maestro"
            login $api_version
            startMaestro
            ;;

        "Navigator (beta)")
            api_version="Navigator"
            login $api_version
            startNavigator
            ;;

        Connected_Fields)
            api_version="ConnectedFields"
            login $api_version
            startConnectedFields
            ;;

        Workspaces)
            api_version="Workspaces"
            login $api_version
            startWorkspaces
            ;;

        Exit)
            exit 0
            ;;
        esac
    done
}

# Select the action
function startSignature() {
    echo "Select the action"
    PS3='Select the action : '
    select CHOICE in \
        "Embedded_Signing" \
        "Signing_Via_Email" \
        "List_Envelopes" \
        "Envelope_Info" \
        "Envelope_Recipients" \
        "Envelope_Docs" \
        "Envelope_Get_Doc" \
        "Create_Template" \
        "Use_Template" \
        "Send_Binary_Docs" \
        "Embedded_Sending" \
        "Embedded_Console" \
        "Add_Doc_To_Template" \
        "Collect_Payment" \
        "Envelope_Tab_Data" \
        "Set_Tab_Values" \
        "Set_Template_Tab_Values" \
        "Envelope_Custom_Field_Data" \
        "Signing_Via_Email_With_Access_Code" \
        "Signing_Via_Email_With_Phone_Authentication" \
        "================Do_Not_Use==================" \
        "Signing_Via_Email_With_Knowledge_Based_Authentication" \
        "Signing_Via_Email_With_IDV_Authentication" \
        "Creating_Permission_Profiles" \
        "Setting_Permission_Profiles" \
        "Updating_Individual_Permission" \
        "Deleting_Permissions" \
        "Creating_A_Brand" \
        "Applying_Brand_Envelope" \
        "Applying_Brand_Template" \
        "Bulk_Sending" \
        "Pause_Signature_Workflow" \
        "Unpause_Signature_Workflow" \
        "Use_Conditional_Recipients" \
        "Scheduled_Sending" \
        "Delayed_Routing" \
        "Signing_Via_SMS_or_WhatsApp" \
        "Create_Signable_HTML_document" \
        "In_Person_Signing" \
        "Set_Document_Visibility" \
        "Shared_Access" \
        "Document_Generation" \
        "Focused_View" \
        "Pick_An_API"; do
        case "$CHOICE" in
        Pick_An_API)
            choices "pick_api"
            ;;
        Embedded_Signing)
            bash eg001EmbeddedSigning.sh
            startSignature
            ;;
        Signing_Via_Email)
            bash examples/eSignature/eg002SigningViaEmail.sh
            startSignature
            ;;
        List_Envelopes)
            bash examples/eSignature/eg003ListEnvelopes.sh
            startSignature
            ;;
        Envelope_Info)
            bash examples/eSignature/eg004EnvelopeInfo.sh
            startSignature
            ;;
        Envelope_Recipients)
            bash examples/eSignature/eg005EnvelopeRecipients.sh
            startSignature
            ;;
        Envelope_Docs)
            bash examples/eSignature/eg006EnvelopeDocs.sh
            startSignature
            ;;
        Envelope_Get_Doc)
            bash examples/eSignature/eg007EnvelopeGetDoc.sh
            startSignature
            ;;
        Create_Template)
            bash examples/eSignature/eg008CreateTemplate.sh
            startSignature
            ;;
        Use_Template)
            bash examples/eSignature/eg009UseTemplate.sh
            startSignature
            ;;
        Send_Binary_Docs)
            bash examples/eSignature/eg010SendBinaryDocs.sh
            startSignature
            ;;
        Embedded_Sending)
            bash examples/eSignature/eg011EmbeddedSending.sh
            startSignature
            ;;
        Embedded_Console)
            bash examples/eSignature/eg012EmbeddedConsole.sh
            startSignature
            ;;
        Add_Doc_To_Template)
            bash examples/eSignature/eg013AddDocToTemplate.sh
            startSignature
            ;;
        Collect_Payment)
            bash examples/eSignature/eg014CollectPayment.sh
            startSignature
            ;;
        Envelope_Tab_Data)
            bash examples/eSignature/eg015EnvelopeTabData.sh
            startSignature
            ;;
        Set_Tab_Values)
            bash examples/eSignature/eg016SetTabValues.sh
            startSignature
            ;;
        Set_Template_Tab_Values)
            bash examples/eSignature/eg017SetTemplateTabValues.sh
            startSignature
            ;;
        Envelope_Custom_Field_Data)
            bash examples/eSignature/eg018EnvelopeCustomFieldData.sh
            startSignature
            ;;
        Signing_Via_Email_With_Access_Code)
            bash examples/eSignature/eg019SigningViaEmailWithAccessCode.sh
            startSignature
            ;;
        Signing_Via_Email_With_Phone_Authentication)
            bash examples/eSignature/eg020SigningViaEmailWithPhoneAuthentication.sh
            startSignature
            ;;
        Signing_Via_Email_With_Knowledge_Based_Authentication)
            bash examples/eSignature/eg022SigningViaEmailWithKnowledgeBasedAuthentication.sh
            startSignature
            ;;
        Signing_Via_Email_With_IDV_Authentication)
            bash examples/eSignature/eg023SigningViaEmailWithIDVAuthentication.sh
            startSignature
            ;;
        Creating_Permission_Profiles)
            bash examples/eSignature/eg024CreatingPermissionProfiles.sh
            startSignature
            ;;
        Setting_Permission_Profiles)
            bash examples/eSignature/eg025SettingPermissionProfiles.sh
            startSignature
            ;;
        Updating_Individual_Permission)
            bash examples/eSignature/eg026UpdatingIndividualPermission.sh
            startSignature
            ;;
        Deleting_Permissions)
            bash examples/eSignature/eg027DeletingPermissions.sh
            startSignature
            ;;
        Creating_A_Brand)
            bash examples/eSignature/eg028CreatingABrand.sh
            startSignature
            ;;
        Applying_Brand_Envelope)
            bash examples/eSignature/eg029ApplyingBrandEnvelope.sh
            startSignature
            ;;
        Applying_Brand_Template)
            bash examples/eSignature/eg030ApplyingBrandTemplate.sh
            startSignature
            ;;
        Bulk_Sending)
            bash examples/eSignature/eg031BulkSending.sh
            startSignature
            ;;
        Pause_Signature_Workflow)
            bash examples/eSignature/eg032PauseSignatureWorkflow.sh
            startSignature
            ;;
        Unpause_Signature_Workflow)
            bash examples/eSignature/eg033UnpauseSignatureWorkflow.sh
            startSignature
            ;;
        Use_Conditional_Recipients)
            bash examples/eSignature/eg034UseConditionalRecipients.sh
            startSignature
            ;;
        Scheduled_Sending)
            bash examples/eSignature/eg035ScheduledSending.sh
            startSignature
            ;;
        Delayed_Routing)
            bash examples/eSignature/eg036DelayedRouting.sh
            startSignature
            ;;
        Signing_Via_SMS_or_WhatsApp)
            bash examples/eSignature/eg037SigningViaSMS.sh
            startSignature
            ;;
        Create_Signable_HTML_document)
            bash examples/eSignature/eg038ResponsiveSigning.sh
            startSignature
            ;;
        In_Person_Signing)
            bash examples/eSignature/eg039InPersonSigning.sh
            startSignature
            ;;
        Set_Document_Visibility)
            bash examples/eSignature/eg040SetDocumentVisibility.sh
            startSignature
            ;;
        Document_Generation)
            bash examples/eSignature/eg042DocumentGeneration.sh
            startSignature
            ;;
        Shared_Access)
            bash examples/eSignature/eg043SharedAccess.sh
            startSignature
            ;;
        Focused_View)
            bash examples/eSignature/eg044FocusedView.sh
            startSignature
            ;;
        *)
            echo ""
            startSignature
            ;;
        esac
    done
}

function startCFRSignature() {
    echo "Select the action"
    PS3='Select the action : '
    select CHOICE in \
        "Embedded_Signing_CFR_Part11" \
        "Signing_Via_Email" \
        "List_Envelopes" \
        "Envelope_Info" \
        "Envelope_Recipients" \
        "Envelope_Docs" \
        "Envelope_Get_Doc" \
        "Create_Template" \
        "Use_Template" \
        "Send_Binary_Docs" \
        "Embedded_Sending" \
        "Embedded_Console" \
        "Add_Doc_To_Template" \
        "Envelope_Tab_Data" \
        "Set_Tab_Values" \
        "Set_Template_Tab_Values" \
        "Envelope_Custom_Field_Data" \
        "Signing_Via_Email_With_Knowledge_Based_Authentication" \
        "Signing_Via_Email_With_Access_Code" \
        "Signing_Via_Email_With_IDV_Authentication" \
        "Creating_Permission_Profiles" \
        "Setting_Permission_Profiles" \
        "Updating_Individual_Permission" \
        "Deleting_Permissions" \
        "Creating_A_Brand" \
        "Applying_Brand_Envelope" \
        "Applying_Brand_Template" \
        "Bulk_Sending" \
        "Scheduled_Sending" \
        "Create_Signable_HTML_document" \
        "Pick_An_API"; do
        case "$CHOICE" in
        Pick_An_API)
            choices "pick_api"
            ;;
        Embedded_Signing_CFR_Part11)
            bash examples/eSignature/eg041EmbeddedSigningCFR.sh
            startCFRSignature
            ;;
        Signing_Via_Email)
            bash examples/eSignature/eg002SigningViaEmail.sh
            startCFRSignature
            ;;
        List_Envelopes)
            bash examples/eSignature/eg003ListEnvelopes.sh
            startCFRSignature
            ;;
        Envelope_Info)
            bash examples/eSignature/eg004EnvelopeInfo.sh
            startCFRSignature
            ;;
        Envelope_Recipients)
            bash examples/eSignature/eg005EnvelopeRecipients.sh
            startCFRSignature
            ;;
        Envelope_Docs)
            bash examples/eSignature/eg006EnvelopeDocs.sh
            startCFRSignature
            ;;
        Envelope_Get_Doc)
            bash examples/eSignature/eg007EnvelopeGetDoc.sh
            startCFRSignature
            ;;
        Create_Template)
            bash examples/eSignature/eg008CreateTemplate.sh
            startCFRSignature
            ;;
        Use_Template)
            bash examples/eSignature/eg009UseTemplate.sh
            startCFRSignature
            ;;
        Send_Binary_Docs)
            bash examples/eSignature/eg010SendBinaryDocs.sh
            startCFRSignature
            ;;
        Embedded_Sending)
            bash examples/eSignature/eg011EmbeddedSending.sh
            startCFRSignature
            ;;
        Embedded_Console)
            bash examples/eSignature/eg012EmbeddedConsole.sh
            startCFRSignature
            ;;
        Add_Doc_To_Template)
            bash examples/eSignature/eg013AddDocToTemplate.sh
            startCFRSignature
            ;;
        Envelope_Tab_Data)
            bash examples/eSignature/eg015EnvelopeTabData.sh
            startCFRSignature
            ;;
        Set_Tab_Values)
            bash examples/eSignature/eg016SetTabValues.sh
            startCFRSignature
            ;;
        Set_Template_Tab_Values)
            bash examples/eSignature/eg017SetTemplateTabValues.sh
            startCFRSignature
            ;;
        Envelope_Custom_Field_Data)
            bash examples/eSignature/eg018EnvelopeCustomFieldData.sh
            startCFRSignature
            ;;
        Signing_Via_Email_With_Access_Code)
            bash examples/eSignature/eg019SigningViaEmailWithAccessCode.sh
            startCFRSignature
            ;;
        Signing_Via_Email_With_Knowledge_Based_Authentication)
            bash examples/eSignature/eg022SigningViaEmailWithKnowledgeBasedAuthentication.sh
            startCFRSignature
            ;;
        Signing_Via_Email_With_IDV_Authentication)
            bash examples/eSignature/eg023SigningViaEmailWithIDVAuthentication.sh
            startCFRSignature
            ;;
        Creating_Permission_Profiles)
            bash examples/eSignature/eg024CreatingPermissionProfiles.sh
            startCFRSignature
            ;;
        Setting_Permission_Profiles)
            bash examples/eSignature/eg025SettingPermissionProfiles.sh
            startCFRSignature
            ;;
        Updating_Individual_Permission)
            bash examples/eSignature/eg026UpdatingIndividualPermission.sh
            startCFRSignature
            ;;
        Deleting_Permissions)
            bash examples/eSignature/eg027DeletingPermissions.sh
            startCFRSignature
            ;;
        Creating_A_Brand)
            bash examples/eSignature/eg028CreatingABrand.sh
            startCFRSignature
            ;;
        Applying_Brand_Envelope)
            bash examples/eSignature/eg029ApplyingBrandEnvelope.sh
            startCFRSignature
            ;;
        Applying_Brand_Template)
            bash examples/eSignature/eg030ApplyingBrandTemplate.sh
            startCFRSignature
            ;;
        Bulk_Sending)
            bash examples/eSignature/eg031BulkSending.sh
            startCFRSignature
            ;;
        Scheduled_Sending)
            bash examples/eSignature/eg035ScheduledSending.sh
            startCFRSignature
            ;;
        Create_Signable_HTML_document)
            bash examples/eSignature/eg038ResponsiveSigning.sh
            startCFRSignature
            ;;
        *)
            echo ""
            startCFRSignature
            ;;
        esac
    done
}

# Select the action
function startRooms() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Create_Room_With_Data_Controller" \
        "Create_Room_With_Template_Controller" \
        "Export_Data_From_Room_Controller" \
        "Add_Forms_To_Room_Controller" \
        "Get_Rooms_With_Filters_Controller" \
        "Create_An_External_Form_Fill_Session_Controller" \
        "Create_Form_Group" \
        "Grant_Office_Access_To_Form_Group" \
        "Assign_Form_To_Form_Group" \
        "Pick_An_API"; do
        case "$CHOICE" in

        Pick_An_API)
            choices
            ;;
        Create_Room_With_Data_Controller)
            bash examples/Rooms/eg001CreateRoomWithDataController.sh
            startRooms
            ;;
        Create_Room_With_Template_Controller)
            bash examples/Rooms/eg002CreateRoomWithTemplateController.sh
            startRooms
            ;;
        Export_Data_From_Room_Controller)
            bash examples/Rooms/eg003ExportDataFromRoomController.sh
            startRooms
            ;;
        Add_Forms_To_Room_Controller)
            bash examples/Rooms/eg004AddFormsToRoomController.sh
            startRooms
            ;;
        Get_Rooms_With_Filters_Controller)
            bash examples/Rooms/eg005GetRoomsWithFiltersController.sh
            startRooms
            ;;
        Create_An_External_Form_Fill_Session_Controller)
            bash examples/Rooms/eg006CreateAnExternalFormFillSessionController.sh
            startRooms
            ;;
        Create_Form_Group)
            bash examples/Rooms/eg007CreateFormGroup.sh
            startRooms
            ;;
        Grant_Office_Access_To_Form_Group)
            bash examples/Rooms/eg008AccessFormGroup.sh
            startRooms
            ;;
        Assign_Form_To_Form_Group)
            bash examples/Rooms/eg009AssignFormGroup.sh
            startRooms
            ;;
        *)
            echo "Default action..."
            startRooms
            ;;
        esac
    done
}

function startClick() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Create_Clickwraps" \
        "Activate_Clickwrap" \
        "Create_New_Clickwrap_Version" \
        "Get_List_Of_Clickwraps" \
        "Get_Clickwrap_Responses" \
        "Embed_Clickwrap" \
        "Pick_An_API"; do
        case "$CHOICE" in

        Pick_An_API)
            choices
            ;;
        Create_Clickwraps)
            bash examples/Click/eg001CreateClickwraps.sh
            startClick
            ;;
        Activate_Clickwrap)
            bash examples/Click/eg002ActivateClickwrap.sh
            startClick
            ;;
        Create_New_Clickwrap_Version)
            bash examples/Click/eg003CreateNewClickwrapVersion.sh
            startClick
            ;;
        Get_List_Of_Clickwraps)
            bash examples/Click/eg004GetListOfClickwraps.sh
            startClick
            ;;
        Get_Clickwrap_Responses)
            bash examples/Click/eg005GetClickwrapResponses.sh
            startClick
            ;;
        Embed_Clickwrap)
            bash examples/Click/eg006EmbedClickwrap.sh
            startClick
            ;;

        *)
            echo "Default action..."
            startClick
            ;;
        esac
    done
}

function startMonitor() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Get_Monitoring_Data" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        Get_Monitoring_Data)
            bash examples/Monitor/eg001GetMonitoringData.sh
            startMonitor
            ;;
        *)
            echo "Default action..."
            startMonitor
            ;;
        esac
    done
}

function startAdmin() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Create_New_User_With_Active_Status" \
        "Create_Active_CLM_ESign_User" \
        "Bulk_Export_User_Data" \
        "Add_Users_Via_Bulk_Import" \
        "Audit_Users" \
        "Retrieve_DocuSign_Profile_By_Email_Address" \
        "Retrieve_DocuSign_Profile_By_UserId" \
        "Update_User_Product_Permission_Profile" \
        "Delete_User_Product_Permission_Profile" \
        "Delete_User_Data_Org_Admin" \
        "Delete_User_Data_Account_Admin" \
        "Clone_Account" \
        "Create_Account" \
        "Pick_An_API"; do
        case "$CHOICE" in

        Pick_An_API)
            choices
            ;;
        Create_New_User_With_Active_Status)
            bash examples/Admin/eg001CreateNewUserWithActiveStatus.sh
            startAdmin
            ;;
        Create_Active_CLM_ESign_User)
            bash examples/Admin/eg002CreateActiveCLMESignUser.sh
            startAdmin
            ;;
        Bulk_Export_User_Data)
            bash examples/Admin/eg003BulkExportUserData.sh
            startAdmin
            ;;
        Add_Users_Via_Bulk_Import)
            bash examples/Admin/eg004AddUsersViaBulkImport.sh
            startAdmin
            ;;
        Audit_Users)
            bash examples/Admin/eg005AuditUsers.sh
            startAdmin
            ;;
        Retrieve_DocuSign_Profile_By_Email_Address)
            bash examples/Admin/eg006RetrieveDocuSignProfileByEmailAddress.sh
            startAdmin
            ;;
        Retrieve_DocuSign_Profile_By_UserId)
            bash examples/Admin/eg007RetrieveDocuSignProfileByUserId.sh
            startAdmin
            ;;
        Update_User_Product_Permission_Profile)
            bash examples/Admin/eg008UpdateUserProductPermissionProfile.sh
            startAdmin
            ;;
        Delete_User_Product_Permission_Profile)
            bash examples/Admin/eg009DeleteUserProductPermissionProfile.sh
            startAdmin
            ;;
        Delete_User_Data_Org_Admin)
            bash examples/Admin/eg010DeleteUserDataFromOrganization.sh
            startAdmin
            ;;
        Delete_User_Data_Account_Admin)
            bash examples/Admin/eg011DeleteUserDataFromAccount.sh
            startAdmin
            ;;
        Clone_Account)
            bash examples/Admin/eg012CloneAccount.sh
            startAdmin
            ;;
        Create_Account)
            bash examples/Admin/eg013CreateAccount.sh
            startAdmin
            ;;
        *)
            echo "Default action..."
            startAdmin
            ;;
        esac
    done
}


function startIdEvidence() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Retrieve_Events" \
        "Retrieve_Media" \
        "Pick_An_API"; do
        case "$CHOICE" in

        Pick_An_API)
            choices
            ;;
        Retrieve_Events)
            bash examples/IdEvidence/eg001RetrieveEvents.sh
            startIdEvidence
            ;;
        Retrieve_Media)
            bash examples/IdEvidence/eg002RetrieveMedia.sh
            startIdEvidence
            ;;
        *)
            echo "Default action..."
            startIdEvidence
            ;;
        esac
    done
}

function startNotary() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Signature_Request_To_Notary_Group" \
        "Invite_Notary_To_Pool" \
        "Jurisdictions" \
        "Signature_Request_Third_Party_Notary" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        Signature_Request_To_Notary_Group)
            bash examples/Notary/eg001SignatureRequestToNotaryGroup.sh
            startNotary
            ;;
        Invite_Notary_To_Pool)
            bash examples/Notary/eg002InviteNotaryToPool.sh
            startNotary
            ;;
        Jurisdictions)
            bash examples/Notary/eg003Jurisdictions.sh
            startNotary
            ;;
        Signature_Request_Third_Party_Notary)
            bash examples/Notary/eg004SendWithThirdPartyNotary.sh
            startNotary
            ;;
        *)
            echo "Default action..."
            startNotary
            ;;
        esac
    done
}

function startWebForms() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "CreateInstance" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        CreateInstance)
            bash examples/WebForms/eg001CreateInstance.sh
            startWebForms
            ;;
        *)
            echo "Default action..."
            startWebForms
            ;;
        esac
    done
}

function startMaestro() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Trigger_Workflow" \
        "Home"; do
        case "$CHOICE" in
        Home)
            choices
            ;;
        Trigger_Workflow)
            bash examples/Maestro/eg001TriggerWorkflow.sh
            startMaestro
            ;;
        *)
            echo "Default action..."
            startMaestro
            ;;
        esac
    done
}

function startNavigator() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "List_Agreements" \
        "Get_Single_Agreement" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        List_Agreements)
            bash examples/Navigator/eg001ListAgreements.sh
            startNavigator
            ;;
        Get_Single_Agreement)
            bash examples/Navigator/eg002GetSingleAgreement.sh
            startNavigator
            ;;
        *)
            echo "Default action..."
            startNavigator
            ;;
        esac
    done
}

function startConnectedFields() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Set_Connected_Fields" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        Set_Connected_Fields)
            bash examples/ConnectedFields/eg001SetConnectedFields.sh
            startConnectedFields
            ;;
        *)
            echo "Default action..."
            startConnectedFields
            ;;
        esac
    done
}

function startWorkspaces() {
    echo ""
    PS3='Select the action : '
    select CHOICE in \
        "Create_Workspace" \
        "Add_Document_To_Workspace" \
        "Send_Envelope_With_Recipient_Info" \
        "Home"; do
        case "$CHOICE" in

        Home)
            choices
            ;;
        Create_Workspace)
            bash examples/Workspaces/eg001CreateWorkspace.sh
            startWorkspaces
            ;;
        Add_Document_To_Workspace)
            bash examples/Workspaces/eg002AddDocumentToWorkspace.sh
            startWorkspaces
            ;;
        Send_Envelope_With_Recipient_Info)
            bash examples/Workspaces/eg003SendEnvelopeWithRecipientInfo.sh
            startWorkspaces
            ;;
        *)
            echo "Default action..."
            startWorkspaces
            ;;
        esac
    done
}

function continu() {

    isCFR
    if [[ $CFR_STATUS == *"enabled"* ]]; then
        startCFRSignature
    fi

    api_version=$1
    if [[ $api_version == "eSignature" ]]
    then
      startSignature
    elif [[ $api_version == "Rooms" ]]
    then
      startRooms
    elif [[ $api_version == "Click" ]]
    then
      startClick
    elif [[ $api_version == "Monitor" ]]
    then
      startMonitor
    elif [[ $api_version == "idEvidence" ]]
    then
      startIdEvidence
    elif [[ $api_version == "Admin" ]]
    then
      bash ./examples/Admin/utils.sh
      startAdmin
    elif [[ $api_version == "Notary" ]]
    then
      bash ./examples/Admin/utils.sh
      startNotary
    elif [[ $api_version == "WebForms" ]]
    then
      startWebForms
    elif [[ $api_version == "Maestro" ]]
    then
      startMaestro
    elif [[ $api_version == "Navigator" ]]
    then
      startNavigator
    elif [[ $api_version == "ConnectedFields" ]]
    then
      startConnectedFields
    elif [[ $api_version == "Workspaces" ]]
    then
      startWorkspaces
    fi
}

echo ""
echo "Welcome to the Docusign Bash Launcher"

choices