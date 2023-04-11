function CheckForValidCCEmail()
{
  while [[ $CC_EMAIL != *"@"* ]]; do
      echo ""
      echo "Current CC email address is " $CC_EMAIL
      read -p "Enter a CC email address different from the signer email address: " CC_EMAIL
      if [[ $CC_NAME == *"{"* || CC_NAME == "" ]] ; then
          echo ""
          echo "Current CC name is " $CC_NAME
          read -p "Enter a name for the CC recipient: " CC_NAME
      fi
      echo ""
      echo "CC_EMAIL is " $CC_EMAIL
      echo "CC_NAME is " $CC_NAME
done
}

function CheckForValidNotCheckedEmail()
{
while [[ $SIGNER_NOT_CHECKED_EMAIL != *"@"* ]]; do
    echo ""
    read -p "Enter an email address to route to when the checkbox is not checked: " SIGNER_NOT_CHECKED_EMAIL
    if [[ $SIGNER_NOT_CHECKED_NAME == *"{"* || SIGNER_NOT_CHECKED_NAME == "" ]] ; then
        echo ""
        read -p "Enter a name for the recipient when the checkbox is not checked: " SIGNER_NOT_CHECKED_NAME
    fi
    echo ""
    echo "SIGNER_NOT_CHECKED_EMAIL is " $SIGNER_NOT_CHECKED_EMAIL
    echo "SIGNER_NOT_CHECKED_NAME is " $SIGNER_NOT_CHECKED_NAME
done
}

function GetCCPhoneNum()
{
    echo ""
    read -p "Please enter a country phone number prefix for the Carbon Copied recipient: " CC_PHONE_COUNTRY
    read -p "Please enter an SMS-enabled Phone number for the Carbon Copied recipient: " CC_PHONE_NUMBER
    CC_PHONE_NUMBER="${CC_PHONE_NUMBER//[!0-9]/}"
    echo ""
}

function GetSignerPhoneNum()
{
    echo ""
    read -p "Please enter a country phone number prefix for the Signer: " SIGNER_PHONE_COUNTRY
    read -p "Please enter an SMS-enabled Phone number for the Signer: " SIGNER_PHONE_NUMBER
    SIGNER_PHONE_NUMBER="${SIGNER_PHONE_NUMBER//[!0-9]/}"
    echo ""
}

function GetSignerEmail()
{
  while [[ $EMAIL != *"@"* ]]; do
      echo ""
      read -p "Enter an email address for the signer: " EMAIL
      read -p "Enter a name for the signer: " NAME
      echo ""
      echo "EMAIL is " $EMAIL
      echo "NAME is " $NAME
done
}

function GetWorkflowId()
{

    index=-1
    workflowFound=false
    eval "arrWorkflowNames=($1)"
    element=$2
    arrWorkflowIds=($3)

    for i in "${!arrWorkflowNames[@]}";
    do
        if [[ "${arrWorkflowNames[$i]}" = "${element}" ]];
        then
            index=$i
            workflowFound=true
            break
        fi
    done

    if [ "$workflowFound" == true ]; then
        workflowId=${arrWorkflowIds[$index]}
        echo $workflowId  
    else
        workflowId=false
        echo $workflowId
    fi
}
function SharedAccessChooseLanguage(){
    echo ""
    api_version=$1
    PS3='Choose an cool OAuth Strategy: '
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
            continue
        esac
    done
    return 0
}

function SharedAccessLogin() {
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
            return
            ;;

            Use_JSON_Web_Token)
            SharedAccessChooseLanguage "$api_version"
            return
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
    return 0

}

export -f GetSignerEmail
export -f CheckForValidCCEmail
export -f CheckForValidNotCheckedEmail
export -f GetCCPhoneNum
export -f GetSignerPhoneNum
export -f GetWorkflowId
export -f SharedAccessLogin
export -f SharedAccessChooseLanguage