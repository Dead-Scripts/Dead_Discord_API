Citizen.CreateThread(function()
    local updatePath = "/JaredScar/Dead_Discord_API" -- your git user/repo path
    local resourceName = "Dead_Discord_API ("..GetCurrentResourceName()..")" -- the resource name
    
    function checkVersion(err, responseText, headers)
        local curVersion = LoadResourceFile(GetCurrentResourceName(), "version.txt")
        if not curVersion then
            print("["..resourceName.."] ERROR: version.txt not found or failed to load.")
            return
        end
        
        -- Trim whitespace / newlines
        curVersion = curVersion:gsub("%s+", "")
        responseText = responseText:gsub("%s+", "")

        if tonumber(curVersion) and tonumber(responseText) then
            if tonumber(curVersion) < tonumber(responseText) then
                print("\n###############################")
                print("\n"..resourceName.." is outdated, should be: "..responseText.."\nis: "..curVersion.."\nplease update it from https://github.com"..updatePath.."")
                print("\n###############################")
            elseif tonumber(curVersion) > tonumber(responseText) then
                print("You somehow skipped a few versions of "..resourceName.." or the git went offline, if it's still online I advise you to update...")
            else
                print("\n"..resourceName.." is up to date!")
            end
        else
            print("["..resourceName.."] ERROR: Version check failed due to invalid version format.")
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/main/version.txt", checkVersion, "GET")
end)