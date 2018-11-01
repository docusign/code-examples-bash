# API code examples with Curl

### Github repo: eg-03-curl
## Introduction
This repo includes bash scripts that use curl to demonstrate:

1. **Embedded Signing Ceremony.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg001EmbeddedSigning.sh)
   This example sends an envelope, and then uses an embedded signing ceremony for the first signer.
   With embedded signing, the DocuSign signing ceremony is initiated from your website.
1. **Send an envelope with a remote (email) signer and cc recipient.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg002SigningViaEmail.sh)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg003ListEnvelopes.sh)
1. **Get an envelope's basic information.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg004EnvelopeInfo.sh)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients** 
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg005EnvelopeRecipients.sh)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg006EnvelopeDocs.sh)
1. **Download an envelope's documents.** 
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg007EnvelopeGetDoc.sh)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg008CreateTemplate.sh)
1. **Send an envelope using a template.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg009UseTemplate.sh)
1. **Send an envelope and upload its documents with multpart binary transfer.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg010SendBinaryDocs.sh)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Embedded sending.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg011EmbeddedSending.sh)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update 
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg012EmbeddedConsole.sh)
1. **Embedded Signing Ceremony from a template with an added document.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg013AddDocToTemplate.sh)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments example: an order form, with online payment by credit card.**
   [Source.](https://github.com/LarryKlugerDS/eg-03-curl/blob/master/examples/eg014CollectPayment.sh)

## Installation

Download or clone this repository to your workstation

### Configure the examples' settings
Each code example is a standalone file. You will configure
each of the example files by setting the variables at the top of each
file:

 * **Access token:** Use the [OAuth Token Generator](https://developers.docusign.com/oauth-token-generator).
   To use the token generator, you'll need a
   [free DocuSign Developer's account.](https://go.docusign.com/o/sandbox/)

   Each access token lasts 8 hours, you will need to repeat this process
   when the token expires. You can use the same access token for
   multiple examples.

 * **Account Id:** After logging into the [DocuSign Sandbox system](https://demo.docusign.net),
   you can copy your Account Id from the dropdown menu by your name. See the figure:

   ![Figure](https://raw.githubusercontent.com/docusign/qs-python/master/documentation/account_id.png)
 * **Signer name and email:** Remember to try the DocuSign signing ceremony using both a mobile phone and a regular
   email client.

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
