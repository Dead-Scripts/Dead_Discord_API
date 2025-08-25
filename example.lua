RegisterCommand('testResource', function(source, args, rawCommand)
    local user = source

    local roleName = "Founder"
    local roleID = GetRoleIdFromRoleName(roleName)
    print("[Dead_Perms Example] The roleID for (" .. roleName .. ") is: " .. tostring(roleID))

    local isVerified = IsDiscordEmailVerified(user)
    print("[Dead_Perms Example] Player " .. GetPlayerName(user) .. " has Discord email verified?: " .. tostring(isVerified))

    local emailAddr = GetDiscordEmail(user)
    print("[Dead_Perms Example] Player " .. GetPlayerName(user) .. " has Discord email address: " .. tostring(emailAddr))

    local name = GetDiscordName(user)
    print("[Dead_Perms Example] Player " .. GetPlayerName(user) .. " has Discord name: " .. tostring(name))

    local icon_URL = GetGuildIcon()
    print("[Dead_Perms Example] Guild icon URL is: " .. tostring(icon_URL))

    local splash_URL = GetGuildSplash()
    print("[Dead_Perms Example] Guild splash URL is: " .. tostring(splash_URL))

    local guildName = GetGuildName()
    print("[Dead_Perms Example] Guild name is: " .. tostring(guildName))

    local guildDesc = GetGuildDescription()
    print("[Dead_Perms Example] Guild description is: " .. tostring(guildDesc))

    local guildMemCount = GetGuildMemberCount()
    print("[Dead_Perms Example] Guild member count is: " .. tostring(guildMemCount))

    local onlineMemCount = GetGuildOnlineMemberCount()
    print("[Dead_Perms Example] Guild online member count is: " .. tostring(onlineMemCount))

    local avatar = GetDiscordAvatar(user)
    print("[Dead_Perms Example] Player " .. GetPlayerName(user) .. " has Discord avatar: " .. tostring(avatar))

    local nickname = GetDiscordNickname(user)
    print("[Dead_Perms Example] Player " .. GetPlayerName(user) .. " has Discord nickname: " .. tostring(nickname))

    local roles = GetGuildRoleList()
    if roles then
        for roleName, roleID in pairs(roles) do 
            print(roleName .. " === " .. roleID)
        end
    else
        print("No guild roles found")
    end

    local userRoles = GetDiscordRoles(user)
    if userRoles then
        for i = 1, #userRoles do  
            print(userRoles[i])
        end
    else
        print("No roles found for user " .. GetPlayerName(user))
    end

    local isRolesEqual = CheckEqual("Founder", 597446100206616596)
    print("Is Founder equal to 597446100206616596? " .. tostring(isRolesEqual))

    local isRolesEqual2 = CheckEqual("FounderRef", "Founder")
    print("Is FounderRef equal to Founder? " .. tostring(isRolesEqual2))

    SetNickname(user, "🦡Dead", "Set nickname")
    SetNickname(user, "", "Reset nickname")

    AddRole(user, "1038448129709723670", "Add role")
    SetRoles(user, { "1038448129709723670" }, "Set roles")
    RemoveRole(user, "1038448129709723670", "Remove role")

    ChangeDiscordVoice(user, 123456789123456789)
    ChangeDiscordVoice(user, 123456789123456789, "Moved "..GetPlayerName(user).." to the admin channel")
end)