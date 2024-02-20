fx_version 'cerulean'
game 'gta5'
author 'Pb'
description ''

ui_page 'ui/index.html'
lua54 'yes'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/img/pixolo.png'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}