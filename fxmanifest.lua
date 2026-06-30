fx_version 'cerulean'
game 'gta5'

name 'ui'
description 'UI for TMFRZ'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    '@core/modules/playerdata.lua',
    'client/main.lua',
    'client/uis/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/uis/*.lua'
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'