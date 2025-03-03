fx_version 'cerulean'
game 'gta5'

author 'gr4cka'
version '1.1'
description 'Enhanced HUD with multi-framework support'

shared_script 'config.lua'
client_script 'client.lua'

files {
	'ui/dist/index.html',
	'ui/dist/assets/*.js',
    'ui/dist/assets/*.css',
}

ui_page 'ui/dist/index.html'

lua54 'yes'
