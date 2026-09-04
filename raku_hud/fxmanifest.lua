fx_version 'cerulean'
game 'gta5'

name 'raku_hud'
author 'Raku / OpenAI'
description 'Modern ESX Legacy HUD for Raku Roleplay'
version '1.0.0'

lua54 'yes'

shared_script '@es_extended/imports.lua'

client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
