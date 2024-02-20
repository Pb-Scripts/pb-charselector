fx_version 'cerulean'
game 'gta5'
author "Pb"

ui_page 'html/index.html'
lua54 'yes'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'locales/*.json'
}

shared_scripts {
    '@pb-utils/init.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'pb-utils'
}