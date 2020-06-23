set -e

if [ -f "config/settings.txt" ]; then
    . config/settings.txt
fi

if [ -f "config/acg.txt" ]; then
    . config/acg.txt
fi

if [ -f "config/jwt.txt" ]; then
    . config/jwt.txt
fi

if [ -f "config/stripeGateway.txt" ]; then
    . config/stripeGateway.txt
fi


function resetToken {

rm -f config/ds_access_token* || true

}


function login {
echo ""
echo ""


PS3='Select an OAuth method to Authenticate with your DocuSign account: '
select METHOD in \
"Use_Authorization_Code_Grant" \
"Use_JSON_Web_Token" \
"Return" \
# "Use_JSON_Web_Token_wo_Code_Grant_autorization" \


do
case "$METHOD" in


Use_Authorization_Code_Grant)
php ./OAuth/code_grant.php
continu
;;

Use_JSON_Web_Token)
php ./OAuth/jwt.php
continu
;;

# Use_JSON_Web_Token_wo_Code_Grant_autorization)
# php jwt2.php
# continu
# ;;

Return)
oauthSettings
;;

esac
done

mv ds_access_token.txt $token_file_name


ACCOUNT_ID=$API_ACCOUNT_ID
ACCESS_TOKEN=$(cat $token_file_name)

export ACCOUNT_ID
export ACCESS_TOKEN
}


function choices {

PS3='Select the action : '
select CHOICE in  \
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
"Set_Tab_Values"  \
"Set_Template_Tab_Values" \
"Envelope_Custom_Field_Data" \
"Signing_Via_Email_With_Access_Code" \
"Signing_Via_Email_With_Sms_Authentication" \
"Signing_Via_Email_With_Phone_Authentication" \
"Signing_Via_Email_With_Knoweldge_Based_Authentication" \
"Signing_Via_Email_With_IDV_Authentication" \
"Creating_Permission_Profiles" \
"Setting_Permission_Profiles" \
"Updating_Individual_Permission" \
"Deleting_Permissions" \
"Creating_A_Brand" \
"Applying_Brand_Envelope" \
"Applying_Brand_Template" \
"Bulk_Sending" \
"Home" \

do
case "$CHOICE" in

Home) 
oauthSettings
;;
Embedded_Signing) bash examples/eg001EmbeddedSigning.sh 
continu
;;
Signing_Via_Email) bash examples/eg002SigningViaEmail.sh 
continu
;;
List_Envelopes) bash examples/eg003ListEnvelopes.sh 
continu
;;
Envelope_Info) bash examples/eg004EnvelopeInfo.sh 
continu
;;
Envelope_Recipients) bash examples/eg005EnvelopeRecipients.sh 
continu
;;
Envelope_Docs) bash examples/eg006EnvelopeDocs.sh 
continu
;;
Envelope_Get_Doc) bash examples/eg007EnvelopeGetDoc.sh 
continu
;;
Create_Template) bash examples/eg008CreateTemplate.sh 
continu
;;
Use_Template) bash examples/eg009UseTemplate.sh 
continu
;;
Send_Binary_Docs) bash examples/eg010SendBinaryDocs.sh 
continu
;;
Embedded_Sending) bash examples/eg011EmbeddedSending.sh 
continu
;;
Embedded_Console) bash examples/eg012EmbeddedConsole.sh 
continu
;;
Add_Doc_To_Template) bash examples/eg013AddDocToTemplate.sh 
continu
;;
Collect_Payment) bash examples/eg014CollectPayment.sh 
continu
;;
Envelope_Tab_Data) bash examples/eg015EnvelopeTabData.sh 
continu
;;
Set_Tab_Values) bash examples/eg016SetTabValues.sh 
continu
;;
Set_Template_Tab_Values) bash examples/eg017SetTemplateTabValues.sh 
continu
;;
Envelope_Custom_Field_Data) bash examples/eg018EnvelopeCustomFieldData.sh 
continu
;;
Signing_Via_Email_With_Access_Code) bash examples/eg019SigningViaEmailWithAccessCode.sh 
continu
;;
Signing_Via_Email_With_Sms_Authentication) bash examples/eg020SigningViaEmailWithSmsAuthentication.sh 
continu
;;
Signing_Via_Email_With_Phone_Authentication) bash examples/eg021SigningViaEmailWithPhoneAuthentication.sh 
continu
;;
Signing_Via_Email_With_Knoweldge_Based_Authentication) bash examples/eg022SigningViaEmailWithKnoweldgeBasedAuthentication.sh 
continu
;;
Signing_Via_Email_With_IDV_Authentication) bash examples/eg023SigningViaEmailWithIDVAuthentication.sh 
continu
;;
Creating_Permission_Profiles) bash examples/eg024CreatingPermissionProfiles.sh 
continu
;;
Setting_Permission_Profiles) bash examples/eg025SettingPermissionProfiles.sh 
continu
;;
Updating_Individual_Permission) bash examples/eg026UpdatingIndividualPermission.sh 
continu
;;
Deleting_Permissions) bash examples/eg027DeletingPermissions.sh 
continu
;;
Creating_A_Brand) bash examples/eg028CreatingABrand.sh 
continu
;;
Applying_Brand_Envelope) bash examples/eg029ApplyingBrandEnvelope.sh 
continu
;;
Applying_Brand_Template) bash examples/eg030ApplyingBrandTemplate.sh 
continu
;;
Bulk_Sending) bash examples/eg031BulkSending.sh 
continu
;;
*) echo "Default action..."
continu
;;
esac
done


}

function oauthSettings {

echo ""
echo "Welcome to the DocuSign eSignature Bash Launcher"
echo "using Authorization Code grant and JWT grant authentication."
echo ""

if [ -f "config/settings.txt" ]; then
    . config/settings.txt
fi

if [ -f "config/acg.txt" ]; then
    . config/acg.txt
fi

if [ -f "config/jwt.txt" ]; then
    . config/jwt.txt
fi

if [ -f "config/stripeGateway.txt" ]; then
    . config/stripeGateway.txt
fi



PS3='Select one: '
select METHOD in \
"View_Examples" \
"Use_OAuth_To_Login" \
"Configure_Authorization_Code_Grant" \
"Configure_JSON_Web_Token_Grant" \
"Configure_Both_JWT_And_ACG" \
"Configure_Signer_Form_Data" \
"Delete_OAuth_Config_Data" \
"Delete_cache_and_form_data" \
"Exit" \

do
case "$METHOD" in 

Delete_cache_and_form_data)
rm -rf config/PROFILE_NAME
rm -rf config/*ID
rm -rf config/settings.txt


echo ""
echo "Form cache and data deleted successfully."
echo ""
;;


Configure_Authorization_Code_Grant)
resetToken

read -p "Please enter your API Account ID: " API_ACCOUNT_ID
export API_ACCOUNT_ID


read -p "Please enter your Integration Key for ACG: " INTEGRATION_KEY
export INTEGRATION_KEY

read -p "Please enter your Integration Secret for ACG: " INTEGRATION_SECRET
export INTEGRATION_SECRET

CFG="config/acg.txt" 
rm -rf $CFG
touch $CFG

echo API_ACCOUNT_ID='"'$API_ACCOUNT_ID'"' >> $CFG
echo INTEGRATION_KEY='"'$INTEGRATION_KEY'"' >> $CFG
echo INTEGRATION_SECRET='"'$INTEGRATION_SECRET'"' >> $CFG

echo "Authorization Code Grant configuration saved"
echo ""

oauthSettings
;;

Configure_JSON_Web_Token_Grant)

resetToken


read -p "Please enter your API Account ID: " API_ACCOUNT_ID
export API_ACCOUNT_ID

read -p "Please enter your Impersonating user GUID  " IMPERSONATION_USER_GUID
export IMPERSONATION_USER_GUID

read -p "Please enter your Integration Key for JWT: " JWT_INTEGRATION_KEY
export JWT_INTEGRATION_KEY


CFG="config/jwt.txt"
rm -rf $CFG
touch $CFG

echo API_ACCOUNT_ID='"'$API_ACCOUNT_ID'"' >> $CFG
echo IMPERSONATION_USER_GUID='"'$IMPERSONATION_USER_GUID'"' >> $CFG
echo JWT_INTEGRATION_KEY='"'$JWT_INTEGRATION_KEY'"' >> $CFG


echo "JWT configuration saved."
echo ""
oauthSettings
;;

Configure_Both_JWT_And_ACG)
resetToken


read -p "Please enter your API Account ID: " API_ACCOUNT_ID
export API_ACCOUNT_ID

read -p "Please enter your Integration Key for ACG: " INTEGRATION_KEY
export INTEGRATION_KEY
read -p "Please enter your Integration Secret for ACG: " INTEGRATION_SECRET
export INTEGRATION_SECRET

read -p "Please enter your an Impersonating user GUID  " IMPERSONATION_USER_GUID
export IMPERSONATION_USER_GUID

read -p "Please enter your Integration Key for JWT: " JWT_INTEGRATION_KEY
export JWT_INTEGRATION_KEY


CFG="config/acg.txt" 
rm -rf $CFG
touch $CFG

echo API_ACCOUNT_ID='"'$API_ACCOUNT_ID'"' >> $CFG
echo INTEGRATION_KEY='"'$INTEGRATION_KEY'"' >> $CFG
echo INTEGRATION_SECRET='"'$INTEGRATION_SECRET'"' >> $CFG


CFG="config/jwt.txt"
rm -rf $CFG
touch $CFG

echo API_ACCOUNT_ID='"'$API_ACCOUNT_ID'"' >> $CFG
echo IMPERSONATION_USER_GUID='"'$IMPERSONATION_USER_GUID'"' >> $CFG
echo JWT_INTEGRATION_KEY='"'$JWT_INTEGRATION_KEY'"' >> $CFG



echo "Both configurations saved"
oauthSettings
;;

Delete_OAuth_Config_Data)
resetToken


rm -rf config/acg.txt
rm -rf config/jwt.txt
cat '' > config/private.key

echo "All Oauth settings have been deleted"
echo ""
echo ""
oauthSettings
;;

Use_OAuth_To_Login)
login
;;

View_Examples)
choices
;;

Configure_Signer_Form_Data)
read -p "Please enter the signer email [example@domain.com]: " SIGNER_EMAIL
SIGNER_EMAIL=${SIGNER_EMAIL:-"example@domain.com"}
export SIGNER_EMAIL

read -p "Please enter the signer name [Bash Signer]: " SIGNER_NAME
SIGNER_NAME=${SIGNER_NAME:-"Bash Signer"}
export SIGNER_NAME

read -p "Please enter the CC email [bashcarboncopy@example.com]: " CC_EMAIL
CC_EMAIL=${CC_EMAIL:-"bashcarboncopy@example.com"}
export CC_EMAIL


read -p "Please enter the CC name [bash carboncopied]: " CC_NAME
CC_NAME=${CC_NAME:-"bob carboncopied"}
export CC_NAME

CFG="config/settings.txt"
rm -rf $CFG
touch $CFG
echo export SIGNER_EMAIL='"'$SIGNER_EMAIL'"' >> $CFG
echo export SIGNER_NAME='"'$SIGNER_NAME'"' >> $CFG
echo export CC_EMAIL='"'$CC_EMAIL'"' >> $CFG
echo export CC_NAME='"'$CC_NAME'"' >> $CFG

echo "Form settings have been saved."
echo ""

login
;;

Set_OAuth_Keys)
oauthSettings
;;


Exit)
exit 0
;;

esac
done

}

function continu {
echo "press the 'any' key to continue"
read nothin
choices
}

oauthSettings