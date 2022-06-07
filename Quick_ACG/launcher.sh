#!/bin/bash
set -e

api_version=""

if [ ! -f "../config/settings.txt" ]; then
    echo "Error: "
    echo "First copy the file 'config/settings.example.txt' to 'config/settings.txt'."
    echo "Next, fill in your API credentials, Signer name and email to continue."
    echo ""
    exit 1
fi

if [ -f "../config/settings.txt" ]; then
    . ../config/settings.txt
fi

function resetToken() {
    rm -f ../config/ds_access_token* || true
}

function login() {
    php ../OAuth/code_grant.php "eSignature"
    bash ../eg001EmbeddedSigning.sh
    startSignature

    mv ds_access_token.txt $token_file_name

    account_id=$(cat config/API_ACCOUNT_ID)
    ACCESS_TOKEN=$(cat $token_file_name)

    export ACCOUNT_ID
    export ACCESS_TOKEN
}

# Choose an API
function startQuickACG() {
    echo ""
    echo "Authentication in progress, please wait"
    echo ""
    login
}

# Select the action
function startSignature() {
    echo ""
    echo "Pick the next action"
    PS3='Pick the next action: '
    select CHOICE in \
        "Embedded_Signing" \
        "Exit"; do
        case "$CHOICE" in
        Embedded_Signing)
            bash ../eg001EmbeddedSigning.sh
            startSignature
            ;;
        Exit)
            exit 0
            ;;
        esac
    done
}

echo ""
echo "Welcome to the DocuSign Bash Quick Authorization Code Grant Launcher"

startQuickACG
