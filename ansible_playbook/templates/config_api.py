# SSH port for hub console
HUB_SSH_PORT = 7022
HUB_API_PORT = 7080

# Hub name/icon url/version, for display purpose
HUB_NAME = "Studio for {{api_name}}"
HUB_ICON = "http://biothings.io/static/img/{{ api_name | regex_replace('\.info','') }}-logo-shiny.svg"
HUB_VERSION = "master"

USE_RELOADER = True # so no need to restart hub when a datasource has changed

