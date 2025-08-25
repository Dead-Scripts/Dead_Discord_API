### Dead_Discord_API

### GetRoleIdFromRoleName
    GET exports.Dead_Discord_API:GetRoleIdFromRoleName(roleName)
    This export allows you to get a Discord role ID from what it is named on the Guild.
    
    ### Query Parameters
        Name        Type        Description
        roleName    string      The name of the Discord role you want the ID for.

200 Number of role ID will be returned: 
404 Could not find a role with the name provided:

### CheckEqual
    GET exports.Dead_Discord_API:CheckEqual(role1, role2)
    This export allows you to check if a Discord role ID is equal to a Discord role Name, this can also check if a Discord role ID is equal to Dead_Discord_API config's RoleList role reference.
    
    ### Query Parameters
        Name    Type    Description
        role2   number  The 2nd role ID you are comparing.
        role2   string  The 2nd role name or role reference you are comparing.
        role1   number  The role ID.
        role1   string  The role name or role reference

200 Returns true if the roles are considered equal: 
404 Returns false if the roles are not considered equal:

### IsDiscordEmailVerified
    GET exports.Dead_Discord_API:IsDiscordEmailVerified(user)
    This export allows you to check if a player has their Discord email verified.

    ### Query Parameters
        Name    Type    Description
        user    object  Thesource of the player you want to check

### GetDiscordEmail
    GET exports.Dead_Discord_API:GetDiscordEmail(user)
    This export allows you to get a player's Discord email if allowed.

    ### Query Parameter
        Name    Type    Description
        user    object  The source of the player you want to check

200 Returns email of user if found: 
404 Returns nil if not found:

### GetDiscordName
    GET exports.Dead_Discord_API:GetDiscordName(user)
    This export allows you to get a player's Discord name.

    ### Query Parameters
        Name    Type    Description
        user    object  The source of the player you want to check

200 Returns Discord name if found: 
404 Returns nil if not found: 

### GetDiscordAvatar
    GET exports.Dead_Discord_API:GetDiscordAvatar(user)
    This export allows you to get a user's Discord avatar image URL.

    ### Query Parameters
        Name    Type    Description
        user    object  The source of the player you want to check

200 Their Discord avatar image URL returned if found:
404 Returns nil if not found:

### GetDiscordNickname
    GET exports.Dead_Discord_API:GetDiscordNickname(user)
    This export allows you to get a player's Discord nickname on the server.

    ### Query Parameters
        Name    Type    Description
        user    object  The source of the player you want to check

200 Returns Discord Nickname if found:
404 Returns nil if not found:

### GetDiscordRoles
    GET exports.Dead_Discord_API:GetDiscordRoles(user)
    This export allows you to get a player's Discord roles within the server (discord role IDs returned).

    ### Query parameters
        Name    Type    Description
        user    object  The source of the player you want to check

200 Returns array of role IDs if found:
404 Returns false if not found:

### GetGuildIcon
    GET exports.Dead_Discord_API:GetGuildIcon()
    This export allows you to get the server's icon image URL.

200 Returns server icon image URL if found:
404 Returns nil if not found:

### GetGuildSplash
    GET exports.Dead_Discord_API:GetGuildSplash()
    This export allows you to get the server's splash image URL.

200 Returns server splash image URL if found:
404 Returns nil if not found:

### GetGuildName
    GET exports.Dead_Discord_API:GetGuildName()
    This export allows you to get the server's name the script is connected to.

200 Returns server name if found:
404 Returns nil if not found:

### GetGuildDescription
    GET exports.Dead_Discord_API:GetGuildDescription()
    This export allows you to get the server's description the script is connected to.

200 Returns server description if found:
404 Returns nil if not found:

### GetGuildMemberCount
    GET exports.Dead_Discord_API:GetGuildMemberCount()
    This export allows you to get the count of members (including offline members) on the server the script is connected to.

200 Returns member count if found:
404 Returns nil if not found:

### GetGuildOnlineMemberCount
    GET exports.Dead_Discord_API:GetGuildOnlineMemberCount()
    This export allows you to get the count of online members on the server the script is connected to.

200 Returns online member count of server if found:
404 Returns nil if not found:

### GetGuildRoleList
    GET exports.Dead_Discord_API:GetGuildRoleList()
    This export allows you to get all of the server's roles with their role names and role IDs correspondent to each other.

200 Returns associative array if found:
404 Returns nil if not found:
