from json import dumps, loads

def filter_by_verify_action(data: str) -> str:
    """
    Filters items where any tab contains 'Verify' in the actionContract.
    """
    return dumps([
        item for item in loads(data)
        if any(
            ("extensionData" in tab and "actionContract" in tab["extensionData"] and "Verify" in tab["extensionData"]["actionContract"]) or
            ("tabLabel" in tab and "connecteddata" in tab["tabLabel"])
            for tab in item.get("tabs", [])
        )
    ])

def extract_unique_apps(data: str):
    """
    Extracts unique appId and applicationName pairs from data.
    """
    unique_apps = {}
    for item in loads(data):
        app_id = item.get('appId', '')
        application_name = item.get('tabs', [{}])[0].get('extensionData', {}).get('applicationName', '')
        if app_id != '' and application_name != '':
            unique_apps[app_id] = application_name
            
    return '\n'.join([f'{app_id} {application_name}' for app_id, application_name in unique_apps.items()])
 
def filter_by_app_id(data: str, chosen_app_id: str) -> str:
    """
    Filters items based on a given appId.
    """
    return dumps([item for item in loads(data) if item.get('appId') == chosen_app_id])

def get_app_id(data: str) -> str:
    return loads(data)[0].get('appId', '')

def get_extension_group_id(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('extensionGroupId', '')

def get_publisher_name(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('publisherName', '')

def get_application_name(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('applicationName', '')

def get_action_name(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('actionName', '')

def get_action_input_key(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('actionInputKey', '')

def get_action_contract(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('actionContract', '')

def get_extension_name(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('extensionName', '')

def get_extension_contract(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('extensionContract', '')

def get_required_for_extension(data: str) -> str:
    return loads(data)[0]['tabs'][0]['extensionData'].get('requiredForExtension', '')

def get_tab_label(data: str) -> str:
    return ' '.join([tab['tabLabel'] for tab in loads(data)[0].get('tabs', [])])

def get_connection_key(data: str) -> str:
    connection_instances = loads(data)[0]['tabs'][0]['extensionData'].get('connectionInstances', [])
    return connection_instances[0].get('connectionKey', '') if len(connection_instances) > 0 else ''

def get_connection_value(data: str) -> str:
    connection_instances = loads(data)[0]['tabs'][0]['extensionData'].get('connectionInstances', [])
    return connection_instances[0].get('connectionValue', '') if len(connection_instances) > 0 else ''
