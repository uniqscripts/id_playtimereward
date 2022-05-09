fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name "id_playtimereward"
description "Playtime Reward"
author "grandson#6863"
version "1.1.2"

client_scripts {
    'client/*.lua',
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
	'oxmysql', -- better to use oxmysql its faster and its updated like mysql-async..
	'/onesync', -- onesync is required to script work.. because of globalstate
	'es_extended'
}
