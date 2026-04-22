fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Sobing4413'
name 'exter-lumberjack'
description 'Lumberjack 4.0'

version '1.0.0'

client_scripts {
	'client/core.lua',
	'client/**.lua',
}

server_scripts {	
	'server/core.lua',
	'server/**.lua',
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/config.lua',
}

escrow_ignore {
	'shared/**',
	'server/**',
	'client/**',
}
