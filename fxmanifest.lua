fx_version 'cerulean'
game 'gta5'

author 'Dead Scripts'
description 'Dead\'s Discord API'
version '1.0'

client_scripts {
    'client.lua',
}

server_scripts {
    'config.lua',
    "server.lua", -- Uncomment this line
    -- "example.lua" -- Remove this when you start using the script!
}

server_exports {
    "GetDiscordRoles",
   	"GetRoleIdFromRoleName",
	"GetDiscordAvatar",
	"GetDiscordName",
	"GetDiscordEmail",
	"IsDiscordEmailVerified",
	"GetDiscordNickname",
	"GetGuildIcon",
	"GetGuildSplash",
	"GetGuildName",
	"GetGuildDescription",
	"GetGuildMemberCount",
	"GetGuildOnlineMemberCount",
	"GetGuildRoleList",
	"ResetCaches",
	"CheckEqual",
	"SetNickname",
	"SetRoles",
	"AddRole",
	"RemoveRole",
	"ChangeDiscordVoice",
	"ClearCache",
	"FetchRoleID"
}