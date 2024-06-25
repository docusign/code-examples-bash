# Bash Launcher Code Examples
>
>### PLEASE! Share your feedback in a [two questions survey](https://docs.google.com/forms/d/e/1FAIpQLScPa74hwhJwi7XWDDj4-XZVOQTF9jJWgbIFEpulXokCqYWT4A/viewform?usp=pp_url&entry.680551577=Bash).
>
>
### GitHub repo: [code-examples-bash](./README.md)

This GitHub repo includes code examples for the [Web Forms API](https://developers.docusign.com/docs/web-forms-api/), [Maestro API](https://developers.docusign.com/docs/maestro-api/), [Docusign Admin API](https://developers.docusign.com/docs/admin-api/), [Click API](https://developers.docusign.com/docs/click-api/), [eSignature REST API](https://developers.docusign.com/docs/esign-rest-api/), [Monitor API](https://developers.docusign.com/docs/monitor-api/), and [Rooms API](https://developers.docusign.com/docs/rooms-api/). 


## Introduction

This repo is a collection of Bash scripts that support the following authentication workflows:

* Authentication with DocuSign via [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode).
When the token expires, the user is asked to re-authenticate. The refresh token is not used.

* Authentication with DocuSign via [JSON Web Token (JWT) Grant](https://developers.docusign.com/platform/auth/jwt/).
When the token expires, it updates automatically.

## eSignature REST API

For more information about the scopes used for obtaining authorization to use the eSignature REST API, see [Required scopes](https://developers.docusign.com/docs/esign-rest-api/esign101/auth#required-scopes).  

For a list of code examples that use the eSignature REST API, see the [How-to guides overview](https://developers.docusign.com/docs/esign-rest-api/how-to/) on the DocuSign Developer Center.


## Admin API

**Note:** To use the Admin API, you must [create an organization](https://support.docusign.com/en/guides/org-admin-guide-create-org) in your DocuSign developer account. Also, to run the DocuSign CLM code example, [CLM must be enabled for your organization](https://support.docusign.com/en/articles/DocuSign-and-SpringCM).

For information about the scopes used for obtaining authorization to use the Admin API, see the [scopes section](https://developers.docusign.com/docs/admin-api/admin101/auth/).

For a list of code examples that use the Admin API, see the [How-to guides overview](https://developers.docusign.com/docs/admin-api/how-to/) on the DocuSign Developer Center.


## Click API  
For more information about the scopes used for obtaining authorization to use the Click API, see [Required scopes](https://developers.docusign.com/docs/click-api/click101/auth/#required-scopes)  

For a list of code examples that use the Click API, see the [How-to guides overview](https://developers.docusign.com/docs/click-api/how-to/) on the DocuSign Developer Center.


## ID Evidence API

**Note:** To run the ID Evidence code examples, you must first complete the [Prerequisites](https://developers.docusign.com/docs/idevidence-api/how-to/retrieve-idevidence-events/).  

For more information about the scopes used for obtaining authorization to use the ID Evidence API, see [Required scopes](https://developers.docusign.com/docs/esign-rest-api/esign101/auth#required-scopes).  

For a list of code examples that use the ID Evidence API, see the [How-to guides overview](https://developers.docusign.com/docs/idevidence-api/how-to/) on the DocuSign Developer Center.

## Maestro API (beta)

**Note:** Maestro API is currently only avaiable for developers that participate in the [beta program](https://developers.docusign.com/docs/maestro-api/get-access/). 

For information about the scopes used for obtaining authorization to use the Maestro API, see the [scopes section](https://developers.docusign.com/docs/maestro-api/auth/).

For a list of code examples that use the Maestro API, see the [How-to guides overview](https://developers.docusign.com/docs/maestro-api/how-to/) on the DocuSign Developer Center.

## Monitor API

**Note:** To use the Monitor API, you must also [enable DocuSign Monitor for your organization](https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/).  

For information about the scopes used for obtaining authorization to use the Monitor API, see the [scopes section](https://developers.docusign.com/docs/monitor-api/monitor101/auth/). 

For a list of code examples that use the Monitor API, see the [How-to guides overview](https://developers.docusign.com/docs/monitor-api/how-to/) on the DocuSign Developer Center.


## Notary API (closed beta)

**Note:** For closed beta participants interested in adding Notary API functionality to your production account, contact your DocuSign representative. 

Example 1 requires a Sender DocuSign developer account API account ID that has been provisioned for the [Notary API base URI](https://developers.docusign.com/docs/notary-api/go-live/). 

Example 2 requires that you [create an organization](https://support.docusign.com/en/guides/org-admin-guide-create-org) in your Sender DocuSign developer account.

For information about the scopes used for obtaining authorization to use the Notary API, see the [scopes section](https://developers.docusign.com/docs/notary-api/notary101/auth/).

For a list of code examples that use the Notary API, see the [How-to guides overview](https://developers.docusign.com/docs/notary-api/how-to/) on the DocuSign Developer Center.


## Rooms API 

**Note:** To use the Rooms API, you must also [create your Rooms developer account](https://developers.docusign.com/docs/rooms-api/rooms101/create-account). Examples 4 and 6 require that you have the DocuSign Forms feature enabled in your Rooms for Real Estate account.  

For more information about the scopes used for obtaining authorization to use the Rooms API, see [Required scopes](https://developers.docusign.com/docs/rooms-api/rooms101/auth/).  

For a list of code examples that use the Rooms API, see the [How-to guides overview](https://developers.docusign.com/docs/rooms-api/how-to/) on the DocuSign Developer Center.

## Web Forms API

The Web Forms API is available in all developer accounts, but only in certain production account plans. Contact [DocuSign Support](https://support.docusign.com/) or your account manager to find out whether the Web Forms API is available for your production account plan.

For more information about the scopes used for obtaining authorization to use the Rooms API, see [Required scopes](https://developers.docusign.com/docs/web-forms-api/plan-integration/authentication/).

For a list of code examples that use the Web Forms API, see the [How-to guides overview](https://developers.docusign.com/docs/web-forms-api/how-to/) on the DocuSign Developer Center.


## Installation

### Prerequisites
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip items 1 and 2 as they were automatically performed for you.

1. A free [DocuSign developer account](https://go.docusign.com/o/sandbox/); create one if you don't already have one.
1. A DocuSign app and integration key that is configured for authentication to use either [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) or [JWT Grant](https://developers.docusign.com/platform/auth/jwt/).

   This [video](https://www.youtube.com/watch?v=eiRI4fe5HgM) demonstrates how to obtain an integration key.  

   To use [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/), you will need an integration key and a secret key. See [Installation steps](#installation-steps) for details.  

   To use [JWT Grant](https://developers.docusign.com/platform/auth/jwt/), you will need an integration key, an RSA key pair, and the User ID GUID of the impersonated user. See [Installation steps for JWT Grant authentication](#installation-steps-for-jwt-grant-authentication) for details.  

   For both authentication flows:  
   
   If you use this launcher on your own workstation, the integration key must include a redirect URI of  

   http://localhost:8080/authorization-code/callback  

   If you host this launcher on a remote web server, set your redirect URI as   
   
   {base_url}/authorization-code/callback   
   
   where {base_url} is the URL for the web app.  
   
1. [Git Bash command line](https://gitforwindows.org/), macOS Terminal, or Linux shell  
1. For Authorization Code Grant authentication PHP 8.0.0 is required.
   For JWT Grant authentication, PHP 8.0.0 and Python 3 are required.


### Installation steps
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip step 3 as it was automatically performed for you.

1. Extract the Quickstart ZIP file or download or clone the code-examples-bash repository.
1. In your command-line environment, switch to the folder:  
   `cd <Quickstart folder name>` or `cd code-examples-bash`
1. To configure the launcher for [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) authentication, create a copy of the file config/settings.example.txt and save the copy as config/settings.txt.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in settings.txt as your `INTEGRATION_KEY_AUTH_CODE`.
   1. Generate a secret key, if you don’t already have one. Under **Authentication**, select **+ ADD SECRET KEY**. Copy the secret key and save it in settings.txt as your `SECRET_KEY`.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:8080/authorization-code/callback. Select **SAVE**.   
   1. Set a name and email address for the signer. In settings.txt, save an email address as `SIGNER_EMAIL` and a name as `SIGNER_NAME`.  
**Note:** Protect your personal information. Please make sure that settings.txt will not be stored in your source code repository.
1. Run the launcher: `bash launcher.sh`
1. Select an API when prompted.
1. Select **Authorization Code Grant** when authenticating your account.
1. Select your desired code example.


### Installation steps for JWT Grant authentication
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip step 3 as it was automatically performed for you.

1. Extract the Quickstart ZIP file or download or clone the code-examples-bash repository.
1. In your command-line environment, switch to the folder:  
   `cd <Quickstart folder name>` or `cd code-examples-bash`
1. To configure the launcher for [JWT Grant](https://developers.docusign.com/platform/auth/jwt/) authentication, create a copy of the file config/settings.example.txt and save the copy as config/settings.txt.
   1. Add your User ID. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **My Account Information**, copy the **User ID** GUID and save it in settings.txt as your `IMPERSONATION_USER_GUID`.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in settings.txt as your `INTEGRATION_KEY_JWT`.
   1. Generate an RSA key pair, if you don’t already have one. Under **Authentication**, select **+ GENERATE RSA**. Copy the private key and save it in a new file named config/private.key.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:8080/authorization-code/callback. Select **SAVE**.   
   1. Set a name and email address for the signer. In settings.txt, save an email address as `SIGNER_EMAIL` and a name as `SIGNER_NAME`.  
**Note:** Protect your personal information. Please make sure that settings.txt will not be stored in your source code repository.
1. Run the launcher: `bash launcher.sh`
1. Select an API when prompted.
1. Select **JSON Web Token** when authenticating your account.
1. Select your desired code example.


### Troubleshooting CRLF issue on Unix systems
If you are using a Unix-like operating system (such as Mac or Linux), you may see the following error message when running some examples:

`examples/eSignature/eg002SigningViaEmail.sh: line 148: syntax error: unexpected end of file`

This is because code files use CRLF as the line ending type, which is incompatible with Unix-like operating systems. To fix this issue, follow the steps below:

1. Install [dos2unix](https://linux.die.net/man/1/dos2unix).
1. Convert the files to use LF as the line ending type by running `dos2unix filename.sh`.  
   * Example: `dos2unix eg002SigningViaEmail.sh`
1. Rerun the Bash launcher.


## ACG embedded signing project
See [DocuSign Quickstart overview](https://developers.docusign.com/docs/esign-rest-api/quickstart/overview/#configuration) on the DocuSign Developer Center for more information on how to run the ACG embedded signing project.


## Payments code example
To use the payments code example, create a test payment gateway on the [**Payments**](https://admindemo.docusign.com/authenticate?goTo=payments) page in your developer account. See [Configure a payment gateway](./PAYMENTS_INSTALLATION.md) for details.

Once you've created a payment gateway, save the **Gateway Account ID** GUID to settings.txt.



## License and additional information

### License
This repository uses the MIT License. See [LICENSE](./LICENSE) for details.

### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
