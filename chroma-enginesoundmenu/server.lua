local format = string.format

RegisterCommand("enginesound", function(source, args, rawCommand)
    if not Config.HasPermission(source) then
        Config.Notify(source, 'You do not have permission to use this command!', 'error')
        return
    end
    TriggerClientEvent("Chroma:EngineSounds:OpenMenu", source)
end, false)

RegisterServerEvent("Chroma:EngineSounds:ChangeEngineSound", function(data)
    local src = source

    if not Config.HasPermission(src) then
        -- this is to prevent again any potential exploiters triggering your events
        return Config.BanPlayer(src)
    end

    if type(data) ~= "table" then
        lib.print.error(format("[changeEngineSound] %s [%s] sent invalid data to the server.", GetPlayerName(src), src))
        return
    end

    local entity = NetworkGetEntityFromNetworkId(data.net)
    if not DoesEntityExist(entity) then return end
    Entity(entity).state['vehdata:sound'] = data.sound

    lib.print.debug(format("%s [%s] has changed their engine sound to %s", GetPlayerName(src), src, data.label))
end)

CreateThread(function()
    if not Config.CheckForUpdates then
        print(
        "\n^6chroma-enginesoundmenu ^2has been loaded - enjoy! ^1[VERSION CHECK DISABLED]\n^2For support or issues, please visit ^3https://discord.gg/chromalabs^7")
        return
    end


    -- https://github.com/Blumlaut/FiveM-Resource-Version-Check-Thing/
    local updatePath = "/Gravxd/enginesound-menu"       -- your git user/repo path
    local resourceName = "^6chroma-enginesoundmenu"     -- the resource name

    local function checkVersion(err, responseText, headers)
        local curVersion = LoadResourceFile(GetCurrentResourceName(), "version.txt")     -- make sure the "version" file actually exists in your resource root!
        if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
            print("\n" ..
            resourceName ..
            " ^1is outdated, please update it from:\n^3https://github.com/Gravxd/enginesound-menu/releases/latest\n^1For support or issues, please visit ^3https://discord.gg/chromalabs^7")
        else
            print("\n" ..
            resourceName ..
            " ^2is up to date, and has been loaded - enjoy!\nFor support or issues, please visit ^3https://discord.gg/chromalabs^7")
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com" .. updatePath .. "/main/chroma-enginesoundmenu/version.txt",
        checkVersion, "GET")
end)
