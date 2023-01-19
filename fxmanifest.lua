fx_version 'adamant'

game 'gta5'

description 'ESX Identity'

version '1.2.0'

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/br.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/img/logo.png',
	'html/style.css'
}

dependency {
	'es_extended',
}




client_script '@packmaps/src/c_00.lua'