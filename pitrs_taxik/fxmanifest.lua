
fx_version 'cerulean'
game 'gta5'

author 'Pitrs'
description 'Taxi Service'
version '1.0.0'
lua54 'yes'

shared_scripts {
   -- '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}


dependencies {
    'ox_lib'
}