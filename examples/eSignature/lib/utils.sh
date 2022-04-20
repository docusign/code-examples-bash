function CheckForValidCCEmail()
{
  while [[ $CC_EMAIL != *"@"* ]]; do
      echo ""
      echo "Current cc email address is " $CC_EMAIL
      read -p "Enter an email address for the cc recipient different from the signer: " CC_EMAIL
      if [[ $CC_NAME == *"{"* || CC_NAME == "" ]] ; then
          echo ""
          echo "Current cc name is " $CC_NAME
          read -p "Enter a name for the CC Recipient: " CC_NAME
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

export -f GetSignerEmail
export -f CheckForValidCCEmail
export -f CheckForValidNotCheckedEmail
export -f GetCCPhoneNum
export -f GetSignerPhoneNum
export -f GetWorkflowId