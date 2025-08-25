-- Cleaned Dead_Discord_API Core Functions

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

function sendDebugMessage(msg)
  print("^1[^5Dead_Discord_API^1] ^3" .. msg)
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
    ["X-Audit-Log-Reason"] = reason or "4R_Discord_API"
  })
  while data == nil do Citizen.Wait(0) end
  return data
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
      sendDebugMessage("[GetGuildRoleList] Failed: "..(error_codes_defined[res.code] or res.code))
    end
  end
  return Caches.RoleList[guildId]
end

function GetGuildIcon(guild)
  local guildId = GetGuildId(guild)
  local res = DiscordRequest("GET", ("guilds/%s"):format(guildId), nil)
  if res.code == 200 then
    local data = json.decode(res.data)
    if data.icon then
      local ext = data.icon:sub(1, 2) == "a_" and ".gif" or ".png"
      return ("https://cdn.discordapp.com/icons/%s/%s%s"):format(guildId, data.icon, ext)
    end
  else
    sendDebugMessage("[GetGuildIcon] Failed: "..(error_codes_defined[res.code] or res.code))
  end
  return nil
end

function AddRole(user, roleId, reason)
  local discordId = GetDiscordId(user)
  if discordId then
    local endpoint = ("guilds/%s/members/%s/roles/%s"):format(Config.Guild_ID, discordId, roleId)
    local res = DiscordRequest("PUT", endpoint, nil, reason)
    if res.code ~= 204 then
      sendDebugMessage("[AddRole] Failed: "..(error_codes_defined[res.code] or res.code))
    end
  else
    sendDebugMessage("[AddRole] No Discord ID for user.")
  end
end

function RemoveRole(user, roleId, reason)
  local discordId = GetDiscordId(user)
  if discordId then
    local endpoint = ("guilds/%s/members/%s/roles/%s"):format(Config.Guild_ID, discordId, roleId)
    local res = DiscordRequest("DELETE", endpoint, nil, reason)
    if res.code ~= 204 then
      sendDebugMessage("[RemoveRole] Failed: "..(error_codes_defined[res.code] or res.code))
    end
  else
    sendDebugMessage("[RemoveRole] No Discord ID for user.")
  end
end

function GetDiscordId(user)
  for _, id in ipairs(GetPlayerIdentifiers(user)) do
    local found = id:match("discord:(%d+)")
    if found then return found end
  end
  return nil
end

-- Additional refactored functions can follow same patterns above

Caches = { RoleList = {} }