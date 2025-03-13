shared_script "@SecureServe/module.lua"
fx_version 'cerulean'
game 'gta5'

author 'Peleg'
description 'Peleg Admin Panel'
version '1.1.0'

ui_page 'Nui/index.html'

shared_scripts {
    'Config/config.lua',
}

client_scripts {
    'Client/core.lua',
    'Client/utils.lua',
    'Client/admin.lua',
    'Client/visuals.lua',
    'Client/functions.lua',
    'Client/events.lua',
    'Client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- If you're using oxmysql for database operations
    'Bridge/framework.lua',
    'Server/events.lua',
}

files {
    'Nui/index.html',
    'Nui/app.js',
    'Nui/css/*.css',
}
