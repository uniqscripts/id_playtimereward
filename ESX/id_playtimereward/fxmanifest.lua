fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name "id_playtimereward"
description "Playtime Reward"
author "grandson#6863"
version "1.1.3"

client_scripts {
    'client/*.lua',
    'shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'shared/*.lua',
}

ui_page "web/index.html"

files {
    'web/index.html',
    'web/script.js',
    'web/style.css',
    'web/img/*.png',
}

dependencies {
	'oxmysql',
	'/onesync',
	'es_extended'
}
