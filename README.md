# API code examples with Curl

### Github repo: eg-03-curl
## Introduction
This repo includes bash scripts that use curl to demonstrate:

1. **Embedded Signing Ceremony.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg001EmbeddedSigning.sh)
   This example sends an envelope, and then uses an embedded signing ceremony for the first signer.
   With embedded signing, the DocuSign signing ceremony is initiated from your website.
1. **Send an envelope with a remote (email) signer and cc recipient.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg002SigningViaEmail.sh)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg003ListEnvelopes.sh)
1. **Get an envelope's basic information.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg004EnvelopeInfo.sh)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients** 
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg005EnvelopeRecipients.sh)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg006EnvelopeDocs.sh)
1. **Download an envelope's documents.** 
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg007EnvelopeGetDoc.sh)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg008CreateTemplate.sh)
1. **Send an envelope using a template.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg009UseTemplate.sh)
1. **Send an envelope and upload its documents with multipart binary transfer.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg010SendBinaryDocs.sh)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Embedded sending.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg011EmbeddedSending.sh)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update 
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg012EmbeddedConsole.sh)
1. **Embedded Signing Ceremony from a template with an added document.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg013AddDocToTemplate.sh)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments Example.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg014CollectPayment.sh)
   An order form, with online payment by credit card.
1. **Get the envelope tab data.**
   Retrieve the tab (field) values for all of the envelope's recipients.
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg015EnvelopeTabData.sh)
1. **Set envelope tab values.**
   The example creates an envelope and sets the initial values for its tabs (fields). Some of the tabs
   are set to be read-only, others can be updated by the recipient. The example also stores
   metadata with the envelope.
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg016SetTabValues.sh)
1. **Set template tab values.**
   The example creates an envelope using a template and sets the initial values for its tabs (fields).
   The example also stores metadata with the envelope.
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg017SetTemplateTabValues.sh)
1. **Get the envelope custom field data (metadata).**
   The example retrieves the custom metadata (custom data fields) stored with the envelope.
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg018EnvelopeCustomFieldData.sh)
1. **Send an envelope with a remote (email) signer using Access Code authentication.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg019SigningViaEmailWithAccessCode.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to enter an access code.
1. **Send an envelope with a remote (email) signer using SMS authentication.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg020SigningViaEmailWithSmsAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to supply a verification code sent to them via SMS.
1. **Send an envelope with a remote (email) signer using Phone authentication.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg021SigningViaEmailWithPhoneAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to supply a verification code sent to them via a phone call.
1. **Send an envelope with a remote (email) signer using Knowledge-Based authentication.**
   [Source.](https://github.com/docusign/eg-03-curl/blob/apiv2/examples/eg022SigningViaEmailWithKnoweldgeBasedAuthentication.sh)
   This example sends an envelope using remote (email) signing requiring the recipient to validate their identity via Knowledge-Based authentication.

## Installation

Download or clone this repository to your workstation

### Configure the examples' settings
Each code example is a standalone file. You will configure
each of the example files by setting the variables at the top of each
file:

 * **Access token:** Use the [OAuth Token Generator](https://developers.docusign.com/oauth-token-generator).
   To use the token generator, you'll need a
   [free DocuSign Developer's account.](https://go.docusign.com/sandbox/productshot/?elqCampaignId=16537)

   Each access token lasts 8 hours, you will need to repeat this process
   when the token expires. You can use the same access token for
   multiple examples.

 * **Account Id:** After logging into the [DocuSign Sandbox system](https://demo.docusign.net),
   you can copy your Account Id from the dropdown menu by your name. See the figure:

   ![Figure](https://raw.githubusercontent.com/docusign/qs-python/master/documentation/account_id.png)
 * **Signer name and email:** Remember to try the DocuSign signing ceremony using both a mobile phone and a regular
   email client.

### Payments code example
To use the payments code example, first create a test payments gatway in your account.
Follow the instructions in the
[PAYMENTS_INSTALLATION.md](https://github.com/docusign/eg-03-curl/blob/apiv2/PAYMENTS_INSTALLATION.md)
file.

Then add the payment gateway id to the code example file.

## Run the examples

Use the bash shell to run the examples. 

The examples have been tested on 
Windows using the **Git-Bash** software included with the 
[git for Windows](https://gitforwindows.org/) open source application.

The scripts can also be used with MacOS and Linux systems.

The examples are in the `/examples` directory.

```
bash eg001EmbeddedSigning.sh
bash eg002SigningViaEmail.sh
bash eg003ListEnvelopes.sh
bash eg004EnvelopeInfo.sh
bash eg005EnvelopeRecipients.sh
bash eg006EnvelopeDocs.sh
bash eg007EnvelopeGetDoc.sh
bash eg008CreateTemplate.sh
bash eg009UseTemplate.sh
bash eg010SendBinaryDocs.sh
bash eg011EmbeddedSending.sh
bash eg012EmbeddedConsole.sh
bash eg013AddDocToTemplate.sh
bash eg014CollectPayment.sh
bash eg015GetEnvelopeTabData.sh 
bash eg016SetEnvelopeTabValues.sh
bash eg017SetTemplateTabValues.sh 
bash eg018GetEnvelopeCustomFieldData.sh 
bash eg019SigningViaEmailWithAccessCode.sh
bash eg020SigningViaEmailWithSmsAuthentication.sh
bash eg021SigningViaEmailWithPhoneAuthentication.sh
bash eg022SigningViaEmailWithKnoweldgeBasedAuthentication.sh

# Note: to use example 14 you must also configure a
# payment gateway for your account.
bash eg014CollectPayment.sh
```

## License and additional information

### License
This repository uses the MIT License. See the LICENSE file for more information.

### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
