import uuid
import sys
import os
from os import path


import requests
import jwt
import http.server
import socketserver
from docusign_esign import ApiClient
from docusign_esign.client.api_exception import ApiException
from docusign_esign.client import OAuthUserInfo, Account

from utils import run_server

PORT = 8080

DS_JWT = {
    "ds_client_id": os.environ.get('INTEGRATION_KEY_JWT'),
    "ds_impersonated_user_id": os.environ.get('IMPERSONATION_USER_GUID'),  # The id of the user.
    "private_key_file": "./config/private.key", # Create a new file in your repo source folder named private.key then copy and paste your RSA private key there and save it.
    "authorization_server": "account-d.docusign.com"
}

API_VERSION = sys.argv[1]


SCOPES = [
     "signature"
]

ROOMS_SCOPES = [
    "room_forms", "dtr.rooms.read", "dtr.rooms.write",
    "dtr.documents.read", "dtr.documents.write", "dtr.profile.read",
    "dtr.profile.write", "dtr.company.read", "dtr.company.write"
]

CLICK_SCOPES = [
    "signature", "click.manage", "click.send"
]

ADMIN_SCOPES = [
    "signature", "organization_read", "group_read", "permission_read",
    "user_read", "user_write", "account_read", "domain_read",
    "identity_provider_read", "user_data_redact", "asset_group_account_read",
    "asset_group_account_clone_write", "asset_group_account_clone_read",
    "organization_sub_account_write", "organization_sub_account_read"
]

NOTARY_SCOPES = [
    "signature", "organization_read", "notary_read", "notary_write"
]

WEB_FORMS_SCOPES = [
    "signature", "webforms_read", "webforms_instance_read", "webforms_instance_write"
]

MAESTRO_SCOPES = [
    "signature", "aow_manage"
]

NAVIGATOR_SCOPES = [
    "signature", "adm_store_unified_repo_read"
]

class DSClient:

    ds_app = None

    def _init(cls):
        cls._jwt_auth()

    @classmethod
    def _jwt_auth(cls):
        """JSON Web Token authentication"""

        if (API_VERSION == "Rooms"):
            use_scopes = ROOMS_SCOPES
        elif (API_VERSION == "Click"):
            use_scopes = CLICK_SCOPES
        elif (API_VERSION == "Admin"):
            use_scopes = ADMIN_SCOPES
        elif (API_VERSION == "WebForms"):
            use_scopes = WEB_FORMS_SCOPES
        elif (API_VERSION == "Notary"):
            use_scopes = NOTARY_SCOPES
        elif (API_VERSION == "Maestro"):
            use_scopes = MAESTRO_SCOPES
        elif (API_VERSION == "Navigator"):
            use_scopes = NAVIGATOR_SCOPES
        else:
            use_scopes = SCOPES

        use_scopes.append("impersonation")
        url_scopes = "+".join(use_scopes)

        redirect_uri = "http://localhost:8080/authorization-code/callback"
        consent_url = f"https://{DS_JWT['authorization_server']}/oauth/auth?response_type=code&" \
                      f"scope={url_scopes}&client_id={DS_JWT['ds_client_id']}&redirect_uri={redirect_uri}"

        print(f"\nOpen the following URL in your browser to grant consent to the application:\n{consent_url}\n")

        run_server()
        cls._write_token(use_scopes)


    @classmethod
    def _write_token(cls, scopes):

        api_client = ApiClient()
        api_client.set_base_path(DS_JWT["authorization_server"])
        api_client.set_oauth_host_name(DS_JWT["authorization_server"])
        private_key = cls._get_private_key().encode("ascii").decode("utf-8")

        cls.ds_app = api_client.request_jwt_user_token(
            client_id=DS_JWT["ds_client_id"],
            user_id=DS_JWT["ds_impersonated_user_id"],
            oauth_host_name=DS_JWT["authorization_server"],
            private_key_bytes=private_key,
            expires_in=3600,
            scopes=scopes
        )

        access_token = open("./config/ds_access_token.txt", "w")
        access_token.write(cls.ds_app.access_token)
        access_token.close()

        user_info = api_client.get_user_info(cls.ds_app.access_token)
        accounts = user_info.get_accounts()
        target_account_id = os.environ.get('TARGET_ACCOUNT_ID')
        if target_account_id != "{TARGET_ACCOUNT_ID}":
            api_account_id = open("./config/API_ACCOUNT_ID", "w")
            api_account_id.write(target_account_id)
            api_account_id.close()
        else:
            api_account_id = open("./config/API_ACCOUNT_ID", "w")
            api_account_id.write(accounts[0].account_id)
            api_account_id.close()


    @staticmethod
    def _get_private_key():
        """
        Get the private key from the private.key file
        """
        private_key_file = path.abspath(DS_JWT["private_key_file"])

        if path.isfile(private_key_file):
            with open(private_key_file) as private_key_file:
                private_key = private_key_file.read()
        else:
            private_key = DS_JWT["private_key_file"]

        return private_key


new_client = DSClient()
new_client._jwt_auth()