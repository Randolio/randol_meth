fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Meth Van'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua'
}

client_scripts {
    'bridge/client/**.lua',
    'cl_meth.lua'
}

server_scripts { 
    'bridge/server/**.lua',
    'sv_meth.lua' 
}

lua54 'yes'