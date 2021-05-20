# DocuSign Bash Code Examples


## Introduction
This repo includes a Bash command-line application to demonstrate:


## eSignature API

For more information about the scopes used for obtaining authorization to use the eSignature API, see the [Required Scopes section](https://developers.docusign.com/docs/esign-rest-api/esign101/auth).

1. **Use embedded signing.**

   [Source](./eg001EmbeddedSigning.sh)
   This example sends an envelope, and then uses embedded signing for the first signer.
   With embedded signing, the DocuSign signing is initiated from your website.
1. **Request a signature by email (Remote Signing).**

   [Source](./examples/eSignature/eg002SigningViaEmail.sh)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source](./examples/eSignature/eg003ListEnvelopes.sh)
1. **Get an envelope's basic information.**
   [Source](./examples/eSignature/eg004EnvelopeInfo.sh)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients**
   [Source](./examples/eSignature/eg005EnvelopeRecipients.sh)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source](./examples/eSignature/eg006EnvelopeDocs.sh)
1. **Download an envelope's documents.**
   [Source](./examples/eSignature/eg007EnvelopeGetDoc.sh)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source](./examples/eSignature/eg008CreateTemplate.sh)
1. **Request a signature by email using a template.**
   [Source](./examples/eSignature/eg009UseTemplate.sh)
1. **Send an envelope and upload its documents with multipart binary transfer.**
   [Source](./examples/eSignature/eg010SendBinaryDocs.sh)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Use embedded sending.**
   [Source](./examples/eSignature/eg011EmbeddedSending.sh)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source](./examples/eSignature/eg012EmbeddedConsole.sh)
1. **Use embedded signing from a template with an added document.**
   [Source](./examples/eSignature/eg013AddDocToTemplate.sh)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments Example.**
   [Source](./examples/eSignature/eg014CollectPayment.sh)
   An order form, with online payment by credit card.
1. **Get the envelope tab data.**
   Retrieve the tab (field) values for all of the envelope's recipients.
   [Source](./examples/eSignature/eg015EnvelopeTabData.sh)
1. **Set envelope tab values.**
   The example creates an envelope and sets the initial values for its tabs (fields). Some of the tabs
   are set to be read-only, others can be updated by the recipient. The example also stores
   metadata with the envelope.
   [Source](./examples/eSignature/eg016SetTabValues.sh)
1. **Set template tab values.**
   The example creates an envelope using a template and sets the initial values for its tabs (fields).
   The example also stores metadata with the envelope.
   [Source](./examples/eSignature/eg017SetTemplateTabValues.sh)
1. **Get the envelope custom field data (metadata).**
   The example retrieves the custom metadata (custom data fields) stored with the envelope.
   [Source](./examples/eSignature/eg018EnvelopeCustomFieldData.sh)
1. **Requiring an Access Code for a Recipient**
   [Source](./examples/eSignature/eg019SigningViaEmailWithAccessCode.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to enter an access code.
1. **Send an envelope with a remote (email) signer using SMS authentication.**
   [Source](./examples/eSignature/eg020SigningViaEmailWithSmsAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to supply a verification code sent to them via SMS.
1. **Send an envelope with a remote (email) signer using Phone authentication.**
   [Source](./examples/eSignature/eg021SigningViaEmailWithPhoneAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to supply a verification code sent to them via a phone call.
1. **Send an envelope with a remote (email) signer using Knowledge-Based authentication.**
   [Source](./examples/eSignature/eg022SigningViaEmailWithKnoweldgeBasedAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to validate their identity via Knowledge-Based authentication.
1. **Send an envelope with a remote (email) signer using Identity Verification.**
   [Source](./examples/eSignature/eg023SigningViaEmailWithIDVAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to validate their identity via a government-issued ID.
1. **Creating a permission profile**
   [Source](./examples/eSignature/eg024CreatingPermissionProfiles.sh)
   This code example demonstrates how to create a permission profile using the [Create Permission Profile](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/create) method.
1. **Setting a permission profile**
   [Source](./examples/eSignature/eg025SettingPermissionProfiles.sh)
   This code example demonstrates how to set a user group’s permission profile using the [Update Group](https://developers.docusign.com/esign-rest-api/reference/UserGroups/Groups/update) method.
   You must have already created the permissions profile and the group of users.
1. **Updating individual permission settings**
   [Source](./examples/eSignature/eg026UpdatingIndividualPermission.sh)
   This code example demonstrates how to edit individual permission settings on a permissions profile using the [Update Permission Profile](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/update) method.
1. **Deleting a permission profile**
   [Source](./examples/eSignature/eg027DeletingPermissions.sh)
   This code example demonstrates how to delete a permission profile using the [Delete Permission Profile](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/create) method.
1. **Creating a brand**
   [Source](./examples/eSignature/eg028CreatingABrand.sh)
   This example creates brand profile for an account using the [Create Brand](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountBrands/create) method.
1. **Applying a brand to an envelope**
   [Source](./examples/eSignature/eg029ApplyingBrandEnvelope.sh)
   This code example demonstrates how to apply a brand you've created to an envelope using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method.
   First, creates the envelope and then applies the brand to it.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **Applying a brand to a template**
   [Source](./examples/eSignature/eg030ApplyingBrandTemplate.sh)
   This code example demonstrates how to apply a brand you've created to a template using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method.
   You must have already created the template and the brand.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **Bulk sending envelopes to multiple recipients**
   [Source](./examples/eSignature/eg031BulkSending.sh)
   This code example demonstrates how to send envelopes in bulk to multiple recipients using these methods:
   [Create Bulk Send List](https://developers.docusign.com/esign-rest-api/reference/BulkEnvelopes/BulkSend/createBulkSendList),
   [Create Bulk Send Request](https://developers.docusign.com/esign-rest-api/reference/BulkEnvelopes/BulkSend/createBulkSendRequest).
   Firstly, creates a bulk send recipients list, and then creates an envelope.
   After that, initiates bulk envelope sending.
1. **Pausing a signature workflow Source.**
   [Source](./examples/eSignature/eg032PauseSignatureWorkflow.sh)
   Demonstrates how to create an envelope where the workflow is paused before the envelope is sent to a second recipient.
1. **Unpausing a signature workflow**
   [Source](./examples/eSignature/eg033UnpauseSignatureWorkflow.sh)
   Demonstrates how to resume an envelope workflow that has been paused
1. **Using conditional recipients**
   [Source](./examples/eSignature/eg034UseConditionalRecipients.sh)
   Demonstrates how to create an envelope where the workflow is routed to different recipients based on the value of a transaction.
1. **Request a signature via SMS delivery**
   [Source](./examples/eSignature/eg035SigningViaSMS.sh)
   Demonstrates how to send a signature request via an SMS message using the [Envelopes: create](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method.  


## Rooms API  

For more information about the scopes used for obtaining authorization to use the Rooms API, see the [Required Scopes section](https://developers.docusign.com/docs/rooms-api/rooms101/auth/).

**Note: to use the Rooms API you must also create your DocuSign Developer Account for Rooms. Examples 4 and 6 require that you have the DocuSign Forms feature enabled in your Rooms for Real Estate account.**
1. **Create a room with data.**
   [Source](./examples/Rooms/eg001CreateRoomWithDataController.sh)
   This example creates a new room in your DocuSign Rooms account to be used for a transaction.
1. **Create a room from a template.**
   [Source](./examples/Rooms/eg002CreateRoomWithTemplateController.sh)
   This example creates a new room using a template.
1. **Create a room with Data.**
   [Source](./examples/Rooms/eg003ExportDataFromRoomController.sh)
   This example exports all the available data from a specific room in your DocuSign Rooms account.
1. **Add forms to a room.**
   [Source](./examples/Rooms/eg004AddFormsToRoomController.sh)
   This example adds a standard real estate related form to a specific room in your DocuSign Rooms account.
1. **How to search for rooms with filters.**
   [Source](./examples/Rooms/eg005GetRoomsWithFiltersController.sh)
1. **Create an external form fillable session.**
   [Source.](./examples/Rooms/eg006CreateAnExternalFormFillSessionController.sh)
1. **Create a form group.**
   [Source.](./examples/Rooms/eg007CreateFormGroup.sh)
1. **Grant office access to a form group.**
   [Source.](./examples/Rooms/eg008AccessFormGroup.sh)
1. **Assign a form to a form group.**
   [Source.](./examples/Rooms/eg009AssignFormGroup.sh)


## Click API
1. **Create a Clickwrap.**
   [Source](./examples/Click/eg001CreateClickwraps.sh)
   Demonstrates how to create a Clickwrap that you can embed in your website or app.
1. **Activate a Clickwrap.**
   [Source](./examples/Click/eg002ActivateClickwrap.sh)
   Demonstrates how to activate a new Clickwrap. By default, new Clickwraps are inactive. You must activate your Clickwrap before you can use it.
1. **Create a new Clickwrap version.**
   [Source](./examples/Click/eg003CreateNewClickwrapVersion.sh)
   Demonstrates how to use the Click API to create a new version of a Clickwrap.
1. **Get a list of Clickwraps.**
   [Source](./examples/Click/eg004GetListOfClickwraps.sh)
   Demonstrates how to get a list of Clickwraps associated with a specific DocuSign user.
1. **Get Clickwrap responses.**
   [Source](./examples/Click/eg005GetClickwrapResponses.sh)
   Demonstrates how to get user responses to your Clickwrap agreements.


## Monitor API 

For more information about the scopes used for obtaining authorization to use the Monitor API, see the [Required Scopes section](https://developers.docusign.com/docs/monitor-api/monitor101/auth/).

**Note:** To use the Monitor API you must also [enable DocuSign Monitor for your organization](https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/).

1. **Get Monitoring Data.**
   [Source.](./examples/Monitor/eg001GetMonitoringData.sh)
   Demonstrates how to get and display all of your organization’s monitoring data.


## Admin API 

**Note:** To use the Admin API, you must [create an organization](https://support.docusign.com/en/guides/org-admin-guide-create-org) in your DocuSign account. Additionally, in order to run the v2.1 code examples, [CLM must be enabled for your organization](https://support.docusign.com/en/articles/DocuSign-and-SpringCM).

For more information about the scopes used for obtaining authorization to use the Admin API, see the [scopes section](https://developers.docusign.com/docs/admin-api/admin101/auth/).

1. **Create a new eSignature + CLM user with an active status.**
   [Source.](./examples/Admin/eg002CreateActiveESignCLMUser.sh)
   Demonstrates how to create a new eSignature + CLM user and activate their account automatically. 


## Installation
### Prerequisites
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip items 1 and 2 as they were automatically performed for you.

1. A free [DocuSign developer account](https://go.docusign.com/o/sandbox/); create one if you don't already have one.
1. A DocuSign app and integration key that is configured for authentication to use either [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) or [JWT Grant](https://developers.docusign.com/platform/auth/jwt/).

   This [video](https://www.youtube.com/watch?v=eiRI4fe5HgM) demonstrates how to obtain an integration key.  

   To use [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/), you will need an integration key and a secret key. See [Installation steps](#installation-steps) for details.  

   To use [JWT Grant](https://developers.docusign.com/platform/auth/jwt/), you will need an integration key, an RSA key pair, and the API Username GUID of the impersonated user. See [Installation steps for JWT Grant authentication](#installation-steps-for-jwt-grant-authentication) for details.  

   For both authentication flows:  
   
   If you use this launcher on your own workstation, the integration key must include a redirect URI of  

   http://localhost:8080/authorization-code/callback  

   If you host this launcher on a remote web server, set your redirect URI as   
   
   {base_url}/authorization-code/callback   
   
   where {base_url} is the URL for the web app.  
   
1. [Git Bash command line](https://gitforwindows.org/), macOS Terminal, or Linux shell  


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
   1. Add your API Username. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **My Account Information**, copy the **API Username** GUID and save it in settings.txt as your `IMPERSONATION_USER_GUID`.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in settings.txt as your `INTEGRATION_KEY_JWT`.
   1. Generate an RSA key pair, if you don’t already have one. Under **Authentication**, select **+ GENERATE RSA**. Copy the private key and save it in a new file named config/private.key.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:8080/authorization-code/callback. Select **SAVE**.   
   1. Set a name and email address for the signer. In settings.txt, save an email address as `SIGNER_EMAIL` and a name as `SIGNER_NAME`.  
**Note:** Protect your personal information. Please make sure that settings.txt will not be stored in your source code repository.
1. Run the launcher: `bash launcher.sh`
1. Select an API when prompted.
1. Select **JSON Web Token** when authenticating your account.
1. Select your desired code example.


## Payments code example
To use the payments code example, create a test payment gateway on the [**Payments**](https://admindemo.docusign.com/authenticate?goTo=payments) page in your developer account. See [Configure a payment gateway](./PAYMENTS_INSTALLATION.md) for details.

Once you've created a payment gateway, save the **Gateway Account ID** GUID to settings.txt.



## License and additional information

### License
This repository uses the MIT License. See [LICENSE](./LICENSE) for details.

### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
