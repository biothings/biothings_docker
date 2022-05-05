def validate_plugin_datasource_response(response, **kwargs):
    plugin_id = kwargs["plugin_id"]
    plugin_url = kwargs["plugin_url"]
    assert plugin_id, plugin_url

    data = response.json()
    
    assert data["status"] == "ok"

    plugin_source_data = None
    for source_data in data["result"]:
        if source_data["_id"] != plugin_id:
            continue
        plugin_source_data = source_data
        break

    assert plugin_source_data
    assert plugin_id == plugin_source_data["name"]
    assert plugin_url in plugin_source_data["data_plugin"]["plugin"]["url"]
    assert "github" in plugin_source_data["data_plugin"]["plugin"]["url"]
    assert plugin_source_data["data_plugin"]["plugin"]["active"]
    assert isinstance(plugin_source_data["data_plugin"]["download"], dict)
