-- Dead_Discord_API Core Functions

local FormattedToken = "Bot " .. Config.Bot_Token

local error_codes_defined = {
  [200] = 'OK - The request was completed successfully..!'
, [204] = 'OK - No Content'
, [400] = "Error - Improperly formatted request."
, [401] = 'Error - Missing or invalid Authorization header.'
, [403] = 'Error - No permission for resource.'
, [404] = "Error - Resource doesn't exist."
, [429] = 'Error - Rate limited.'
, [502] = 'Error - Discord API down?'
}

Caches = { RoleList = {}, Roles = {}, Guilds = {} }

function sendDebugMessage(msg)
  if Config.DebugScript then
    print("^1[^5Dead_Discord_API^1] ^3" .. msg .. "^7")
  end
end

local function errorMessage(fn, code)
  print("^1[^5Dead_Discord_API^1] ^1[" .. fn .. "] " .. (error_codes_defined[code] or ("Error - Unknown response code: " .. tostring(code))) .. "^7")
end

function DiscordRequest(method, endpoint, jsondata, reason)
  local data = nil
  local body = ""
  if jsondata then
    if type(jsondata) == "table" then
      body = json.encode(jsondata)
    elseif type(jsondata) == "string" then
      body = jsondata
    end
  end
  PerformHttpRequest("https://discord.com/api/"..endpoint, function(errCode, resultData, resultHeaders)
    data = {data = resultData, code = errCode, headers = resultHeaders}
  end, method, body, {
    ["Content-Type"] = "application/json",
    ["Authorization"] = FormattedToken,
    ["X-Audit-Log-Reason"] = reason or "Dead_Discord_API"
  })
  while data == nil do Citizen.Wait(0) end
  return data
end

function GetGuildId(guild)
  if guild and Config.Multiguild then
    return Config.Guilds[guild] or Config.Guild_ID
  end
  return Config.Guild_ID
end

function GetDiscordId(user)
  for _, id in ipairs(GetPlayerIdentifiers(user)) do
    local found = id:match("discord:(%d+)")
    if found then return found end
  end
  return nil
end

local function GetGuild(guild, withCounts)
  local guildId = GetGuildId(guild)
  local endpoint = ("guilds/%s"):format(guildId)
  if withCounts then endpoint = endpoint .. "?with_counts=true" end
  local res = DiscordRequest("GET", endpoint, nil)
  if res.code == 200 then
    return json.decode(res.data)
  end
  errorMessage("GetGuild", res.code)
  return nil
end

local function GetGuildMember(user, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[GetGuildMember] No Discord identifier for user " .. tostring(user))
    return nil
  end
  local res = DiscordRequest("GET", ("guilds/%s/members/%s"):format(GetGuildId(guild), discordId), nil)
  if res.code == 200 then
    return json.decode(res.data)
  end
  errorMessage("GetGuildMember", res.code)
  return nil
end

function GetGuildRoleList(guild)
  local guildId = GetGuildId(guild)
  if not Caches.RoleList[guildId] then
    local res = DiscordRequest("GET", ("guilds/%s/roles"):format(guildId), nil)
    if res.code == 200 then
      local decoded = json.decode(res.data)
      local roleList = {}
      for _, role in ipairs(decoded) do
        roleList[role.name] = role.id
      end
      Caches.RoleList[guildId] = roleList
    else
      errorMessage("GetGuildRoleList", res.code)
    end
  end
  return Caches.RoleList[guildId]
end

function GetRoleIdFromRoleName(roleName, guild)
  local roleList = GetGuildRoleList(guild)
  if not roleList then return nil end
  if roleList[roleName] then return roleList[roleName] end
  if Config.RoleList and Config.RoleList[roleName] then
    return tostring(Config.RoleList[roleName])
  end
  return nil
end

function FetchRoleID(roleName, guild)
  return GetRoleIdFromRoleName(roleName, guild)
end

-- Resolves either a role name or a role ID down to a role ID string
local function ResolveRole(role, guild)
  if role == nil then return nil end
  local asString = tostring(role)
  if asString:match("^%d+$") then return asString end
  return GetRoleIdFromRoleName(asString, guild)
end

function GetDiscordRoles(user, guild)
  local guildId = GetGuildId(guild)
  local discordId = GetDiscordId(user)
  if not discordId then return false end

  local cacheKey = guildId .. ":" .. discordId
  local cached = Caches.Roles[cacheKey]
  if Config.CacheDiscordRoles and cached and (os.time() - cached.time) < (Config.CacheDiscordRolesTime or 60) then
    return cached.roles
  end

  local member = GetGuildMember(user, guild)
  if not member or not member.roles then return false end

  Caches.Roles[cacheKey] = { roles = member.roles, time = os.time() }
  return member.roles
end

function CheckEqual(roleA, roleB, guild)
  local a = ResolveRole(roleA, guild)
  local b = ResolveRole(roleB, guild)
  if a == nil or b == nil then return false end
  return a == b
end

function GetDiscordName(user)
  local discordId = GetDiscordId(user)
  if not discordId then return nil end
  local res = DiscordRequest("GET", ("users/%s"):format(discordId), nil)
  if res.code == 200 then
    local data = json.decode(res.data)
    if data.discriminator and data.discriminator ~= "0" then
      return data.username, data.discriminator
    end
    return data.username
  end
  errorMessage("GetDiscordName", res.code)
  return nil
end

function GetDiscordNickname(user, guild)
  local member = GetGuildMember(user, guild)
  if not member then return nil end
  return member.nick or (member.user and member.user.username) or nil
end

function GetDiscordAvatar(user, guild)
  local discordId = GetDiscordId(user)
  if not discordId then return nil end
  local res = DiscordRequest("GET", ("users/%s"):format(discordId), nil)
  if res.code == 200 then
    local data = json.decode(res.data)
    if data.avatar then
      local ext = data.avatar:sub(1, 2) == "a_" and ".gif" or ".png"
      return ("https://cdn.discordapp.com/avatars/%s/%s%s"):format(discordId, data.avatar, ext)
    end
    return nil
  end
  errorMessage("GetDiscordAvatar", res.code)
  return nil
end

-- A bot token cannot read member email addresses; that requires an OAuth2 token
-- with the `email` scope, which this resource does not handle.
function GetDiscordEmail(user)
  sendDebugMessage("[GetDiscordEmail] Email is only available through OAuth2, not a bot token.")
  return nil
end

function IsDiscordEmailVerified(user)
  sendDebugMessage("[IsDiscordEmailVerified] Email verification is only available through OAuth2, not a bot token.")
  return false
end

function GetGuildIcon(guild)
  local guildId = GetGuildId(guild)
  local data = GetGuild(guild)
  if data and data.icon then
    local ext = data.icon:sub(1, 2) == "a_" and ".gif" or ".png"
    return ("https://cdn.discordapp.com/icons/%s/%s%s"):format(guildId, data.icon, ext)
  end
  return nil
end

function GetGuildSplash(guild)
  local guildId = GetGuildId(guild)
  local data = GetGuild(guild)
  if data and data.splash then
    return ("https://cdn.discordapp.com/splashes/%s/%s.png"):format(guildId, data.splash)
  end
  return nil
end

function GetGuildName(guild)
  local data = GetGuild(guild)
  return data and data.name or nil
end

function GetGuildDescription(guild)
  local data = GetGuild(guild)
  return data and data.description or nil
end

function GetGuildMemberCount(guild)
  local data = GetGuild(guild, true)
  return data and data.approximate_member_count or nil
end

function GetGuildOnlineMemberCount(guild)
  local data = GetGuild(guild, true)
  return data and data.approximate_presence_count or nil
end

function SetNickname(user, nickname, reason, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[SetNickname] No Discord ID for user.")
    return false
  end
  local endpoint = ("guilds/%s/members/%s"):format(GetGuildId(guild), discordId)
  local res = DiscordRequest("PATCH", endpoint, { nick = nickname }, reason)
  if res.code ~= 200 and res.code ~= 204 then
    errorMessage("SetNickname", res.code)
    return false
  end
  return true
end

function SetRoles(user, roles, reason, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[SetRoles] No Discord ID for user.")
    return false
  end
  local roleIds = {}
  for _, role in ipairs(roles) do
    local resolved = ResolveRole(role, guild)
    if resolved then roleIds[#roleIds + 1] = resolved end
  end
  local endpoint = ("guilds/%s/members/%s"):format(GetGuildId(guild), discordId)
  local res = DiscordRequest("PATCH", endpoint, { roles = roleIds }, reason)
  if res.code ~= 200 and res.code ~= 204 then
    errorMessage("SetRoles", res.code)
    return false
  end
  ClearCache(user, guild)
  return true
end

function AddRole(user, roleId, reason, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[AddRole] No Discord ID for user.")
    return false
  end
  local resolved = ResolveRole(roleId, guild)
  if not resolved then
    sendDebugMessage("[AddRole] Could not resolve role " .. tostring(roleId))
    return false
  end
  local endpoint = ("guilds/%s/members/%s/roles/%s"):format(GetGuildId(guild), discordId, resolved)
  local res = DiscordRequest("PUT", endpoint, nil, reason)
  if res.code ~= 204 then
    errorMessage("AddRole", res.code)
    return false
  end
  ClearCache(user, guild)
  return true
end

function RemoveRole(user, roleId, reason, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[RemoveRole] No Discord ID for user.")
    return false
  end
  local resolved = ResolveRole(roleId, guild)
  if not resolved then
    sendDebugMessage("[RemoveRole] Could not resolve role " .. tostring(roleId))
    return false
  end
  local endpoint = ("guilds/%s/members/%s/roles/%s"):format(GetGuildId(guild), discordId, resolved)
  local res = DiscordRequest("DELETE", endpoint, nil, reason)
  if res.code ~= 204 then
    errorMessage("RemoveRole", res.code)
    return false
  end
  ClearCache(user, guild)
  return true
end

function ChangeDiscordVoice(user, channelId, reason, guild)
  local discordId = GetDiscordId(user)
  if not discordId then
    sendDebugMessage("[ChangeDiscordVoice] No Discord ID for user.")
    return false
  end
  local endpoint = ("guilds/%s/members/%s"):format(GetGuildId(guild), discordId)
  local res = DiscordRequest("PATCH", endpoint, { channel_id = tostring(channelId) }, reason)
  if res.code ~= 200 and res.code ~= 204 then
    errorMessage("ChangeDiscordVoice", res.code)
    return false
  end
  return true
end

function ClearCache(user, guild)
  local discordId = GetDiscordId(user)
  if not discordId then return end
  Caches.Roles[GetGuildId(guild) .. ":" .. discordId] = nil
end

function ResetCaches()
  Caches = { RoleList = {}, Roles = {}, Guilds = {} }
end

-- Warm the role cache once a player has finished loading in
RegisterNetEvent('Dead_Discord_API:PlayerLoaded')
AddEventHandler('Dead_Discord_API:PlayerLoaded', function()
  local src = source
  if not Config.CacheDiscordRoles then return end
  Citizen.CreateThread(function()
    GetDiscordRoles(src)
  end)
end)

AddEventHandler('playerDropped', function()
  ClearCache(source)
end)
