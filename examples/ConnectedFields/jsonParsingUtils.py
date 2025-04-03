from json import dumps, loads

def filter_by_verify_action(filename: str) -> str:
    """
    Filters items where any tab contains 'Verify' in the actionContract and 'connecteddata' in the tabLabel.
    """

    with open(filename) as file:
        data = file.read()

    apps = data[data.find("["):] if "[" in data else ""
    return dumps([
        {"appId": app["appId"], "applicationName": app["tabs"][0]["extensionData"]["applicationName"]}
        for app in loads(apps)
        if "appId" in app and app.get("tabs") and "extensionData" in app["tabs"][0] and "applicationName" in app["tabs"][0]["extensionData"]
        and any(
            ("extensionData" in tab and "actionContract" in tab["extensionData"] and "Verify" in tab["extensionData"]["actionContract"]) or
            ("tabLabel" in tab and "connecteddata" in tab["tabLabel"])
            for tab in app["tabs"]
        )
    ])

def extract_unique_apps(data: str):
    """
    Extracts unique appId and applicationName pairs from data.
    """
    unique_apps = {}
    for item in loads(data):
        app_id = item.get('appId', '')
        application_name = item.get('applicationName', '')
        if app_id != '' and application_name != '':
            unique_apps[app_id] = application_name
            
    return '\n'.join([f'{app_id} {application_name}' for app_id, application_name in unique_apps.items()])
 
def filter_by_app_id(filename: str, chosen_app_id: str) -> str:
    """
    Filters items based on a given appId.
    """
    with open(filename) as file:
        data = file.read()

    apps = data[data.find("["):] if "[" in data else ""

    return dumps([item for item in loads(apps) if item.get('appId') == chosen_app_id])

def extract_verification_data(selected_app_id, tab):
    extension_data = tab["extensionData"]

    return {
        "app_id": selected_app_id,
        "extension_group_id": extension_data["extensionGroupId"] if "extensionGroupId" in extension_data else "",
        "publisher_name": extension_data["publisherName"] if "publisherName" in extension_data else "",
        "application_name": extension_data["applicationName"] if "applicationName" in extension_data else "",
        "action_name": extension_data["actionName"] if "actionName" in extension_data else "",
        "action_input_key": extension_data["actionInputKey"] if "actionInputKey" in extension_data else "",
        "action_contract": extension_data["actionContract"] if "actionContract" in extension_data else "",
        "extension_name": extension_data["extensionName"] if "extensionName" in extension_data else "",
        "extension_contract": extension_data["extensionContract"] if "extensionContract" in extension_data else "",
        "required_for_extension": extension_data["requiredForExtension"] if "requiredForExtension" in extension_data else "",
        "tab_label": tab["tabLabel"],
        "connection_key": (
            extension_data["connectionInstances"][0]["connectionKey"]
            if "connectionInstances" in extension_data and extension_data["connectionInstances"]
            else ""
        ),
        "connection_value": (
            extension_data["connectionInstances"][0]["connectionValue"]
            if "connectionInstances" in extension_data and extension_data["connectionInstances"]
            else ""
        ),
    }

def get_extension_data(verification_data):
    return {
        "extensionGroupId": verification_data["extension_group_id"],
        "publisherName": verification_data["publisher_name"],
        "applicationId": verification_data["app_id"],
        "applicationName": verification_data["application_name"],
        "actionName": verification_data["action_name"],
        "actionContract": verification_data["action_contract"],
        "extensionName": verification_data["extension_name"],
        "extensionContract": verification_data["extension_contract"],
        "requiredForExtension": verification_data["required_for_extension"],
        "actionInputKey": verification_data["action_input_key"],
        "extensionPolicy": 'MustVerifyToSign',
        "connectionInstances": [
            {
                "connectionKey": verification_data["connection_key"],
                "connectionValue": verification_data["connection_value"],
            }
        ]
    }

def make_text_tab(verification_data, extension_data, text_tab_count):
    text_tab = {
        "requireInitialOnSharedChange": "false",
        "requireAll": "false",
        "name": verification_data["application_name"],
        "required": "true",
        "locked": "false",
        "disableAutoSize": "false",
        "maxLength": 4000,
        "tabLabel": verification_data["tab_label"],
        "font": "lucidaconsole",
        "fontColor": "black",
        "fontSize": "size9",
        "documentId": "1",
        "recipientId": "1",
        "pageNumber": "1",
        "xPosition": f"{70 + 100 * int(text_tab_count / 10)}",
        "yPosition": f"{560 + 20 * (text_tab_count % 10)}",
        "width": "84",
        "height": "22",
        "templateRequired": "false",
        "tabType": "text",
        "tooltip": verification_data["action_input_key"],
        "extensionData": extension_data
    }
    return text_tab

def make_text_tabs_list(data: str, selected_app_id: str):
    app = loads(data)[0]
    text_tabs = []
    for tab in (t for t in app["tabs"] if "SuggestionInput" not in t["tabLabel"]):
        verification_data = extract_verification_data(selected_app_id, tab)
        extension_data = get_extension_data(verification_data)

        text_tab = make_text_tab(verification_data, extension_data, len(text_tabs))
        text_tabs.append(text_tab)

    return dumps(text_tabs)
