local DisplayLabels = {}
for k, _ in pairs(Config.EngineSounds) do
    DisplayLabels[#DisplayLabels + 1] = k
end

local format = string.format
local GetEntityModel = GetEntityModel

local storeSoundsForModel = GetResourceKvpInt("storeSoundsForModel") ~= 0 and true or Config.StoreSoundsByModel
lib.print.debug("Store sounds for model: ", storeSoundsForModel)


local Index = 1
local Favourites = {}

local function loadFavourites()
    local jsonFavourites = GetResourceKvpString("favouriteEngineSounds")
    if jsonFavourites then
        Favourites = json.decode(jsonFavourites)
    end
end

local function saveFavourites()
    SetResourceKvp("favouriteEngineSounds", json.encode(Favourites))
end

loadFavourites()

local function showEngineSoundMenu()
    lib.setMenuOptions(
        "engine_sound_menu",
        {
            label = "Change Engine Sound",
            icon = "arrows-up-down-left-right",
            values = DisplayLabels,
            defaultIndex = Index,
            close = false
        },
        1
    )
    lib.setMenuOptions("engine_sound_menu", {label = "Store Sounds Per Model", description = "If you use an engine sound on a vehicle it will save, if you spawn this vehicle again, it will restore that last used engine sound.", checked = storeSoundsForModel, icon = "fa-solid fa-floppy-disk"}, 4)
    lib.showMenu("engine_sound_menu")
end

local function showRemoveFavouritesMenu()
    local removeOptions = {}
    for fav, _ in pairs(Favourites) do
        removeOptions[#removeOptions+1] = { label = fav, icon = 'trash' }
    end

    lib.registerMenu(
        {
            id = "remove_favourites_menu",
            title = "Remove from Favourites",
            position = Config.MenuPosition,
            options = removeOptions,
            onClose = function()
                showFavouritesMenu()
            end
        },
        function(selected)
            local soundToRemove = removeOptions[selected].label
            Favourites[soundToRemove] = nil
            saveFavourites()
            Config.Notify("Engine sound removed from favourites!", "success")
            if next(Favourites) == nil then
                Config.Notify("You have no more favourites!", "info")
                showEngineSoundMenu()
            else
                showRemoveFavouritesMenu()
            end
        end
    )

    lib.showMenu("remove_favourites_menu")
end

local function IsRestricted()
    if LocalPlayer.state.dead then
        return true
    end
    return false
end

function showFavouritesMenu()
    if next(Favourites) == nil then
        Config.Notify("You don't have any favourites!", "error")
        return
    end

    local favouriteOptions = {}
    for fav, _ in pairs(Favourites) do
        favouriteOptions[#favouriteOptions+1] = { label = fav, icon = 'star' }
    end
    favouriteOptions[#favouriteOptions+1] = {label="Remove from Favourites", icon="trash"}

    lib.registerMenu(
        {
            id = "favourites_menu",
            title = "Favourites",
            position = Config.MenuPosition,
            options = favouriteOptions,
            onClose = function()
                showEngineSoundMenu()
            end
        },
        function(selected)
            local selectedFav = favouriteOptions[selected].label
            if selectedFav == "Remove from Favourites" then
                showRemoveFavouritesMenu()
            else
                if not cache.vehicle or cache.seat ~= -1 then
                    return Config.Notify("You need to be driving a vehicle to use this!", "error")
                end

                if IsRestricted() then
                    return Config.Notify("You aren't able to use this right now!", "error")
                end

                TriggerServerEvent(
                    "Chroma:EngineSounds:ChangeEngineSound",
                    {
                        net = VehToNet(cache.vehicle),
                        sound = Config.EngineSounds[selectedFav],
                        label = selectedFav
                    }
                )

                Config.Notify(string.format("Engine sound changed to: %s", selectedFav), "success")
                lib.showMenu("favourites_menu")
            end
        end
    )

    lib.showMenu("favourites_menu")
end

function changeSoundForVehicle(vehicle, sound, label)
    TriggerServerEvent(
        "Chroma:EngineSounds:ChangeEngineSound",
        {
            net = VehToNet(vehicle),
            sound = sound,
            label = label
        }
    )
end

local storedModelSounds = GetResourceKvpString("storedModelSounds") and json.decode(GetResourceKvpString("storedModelSounds")) or {}
lib.print.debug("Stored model sounds: ", json.encode(storedModelSounds, {indent = true, pretty = true}))

lib.onCache("vehicle", function(value)
    if not value then return end
    if not storeSoundsForModel then return end
    local driverPed = GetPedInVehicleSeat(value, -1)
    if driverPed ~= cache.ped then
        lib.print.debug("I am not driver, do not set engine sound.")
        return
    end
    local vehicleModel = GetEntityModel(value)
    lib.print.debug(format("[vehicleChange] Model: %s - %s - %s", vehicleModel, storedModelSounds[vehicleModel], storedModelSounds[tostring(vehicleModel)]))
    local savedModelSound = storedModelSounds[tostring(vehicleModel)]
    if savedModelSound then
        lib.print.debug(format("Found sound for model %s: %s", vehicleModel, savedModelSound.label))
        changeSoundForVehicle(value, savedModelSound.sound, savedModelSound.label)
    end
end)

lib.registerMenu(
    {
        id = "engine_sound_menu",
        title = "Engine Sound Menu",
        position = Config.MenuPosition,
        onSideScroll = function(_, scrollIndex)
            Index = scrollIndex
        end,
        onCheck = function(selected, checked, args)
            if selected == 4 then
                -- store sounds on models
                print(checked)
                storeSoundsForModel = checked
                SetResourceKvpInt("storeSoundsForModel", storeSoundsForModel and 1 or 0)
                if storeSoundsForModel then
                    Config.Notify("Engine sounds will now be stored per model!", "success")
                else
                    Config.Notify("Engine sounds will no longer be stored per model!", "error")
                end

            end
        end,
        options = {
            {label = "Change Engine Sound", icon = "arrows-up-down-left-right", values = DisplayLabels},
            {label = "Add to Favourites", icon = "heart"},
            {label = "View Favourites", icon = "star"},
            {label = "Store Sounds Per Model", description = "If you use an engine sound on a vehicle it will save, if you spawn this vehicle again, it will restore that last used engine sound.", checked = storeSoundsForModel, icon = "fa-solid fa-floppy-disk"}
        }
    },
    function(selected, scrollIndex)
        if selected == 1 then
            -- change engine sound
            if not cache.vehicle or cache.seat ~= -1 then
                return Config.Notify("You need to be driving a vehicle to use this!", "error")
            end

            if IsRestricted() then
                return Config.Notify("You aren't able to use this right now!", "error")
            end

            changeSoundForVehicle(cache.vehicle, Config.EngineSounds[DisplayLabels[scrollIndex]], DisplayLabels[scrollIndex])

            if storeSoundsForModel then
                local vehicleModel = GetEntityModel(cache.vehicle)
                storedModelSounds[tostring(vehicleModel)] = {
                    sound = Config.EngineSounds[DisplayLabels[scrollIndex]],
                    label = DisplayLabels[scrollIndex]
                }
    
                SetResourceKvp("storedModelSounds", json.encode(storedModelSounds))
                lib.print.debug(format("Added sound for model %s: %s", vehicleModel, DisplayLabels[scrollIndex]))
            end

            Config.Notify(string.format("Engine sound changed to: %s", DisplayLabels[scrollIndex]), "success")
            if false then
                lib.hideMenu("engine_sound_menu")
            end
        elseif selected == 2 then
            -- add to favourites
            local soundName = DisplayLabels[Index]
            if not Favourites[soundName] then
                Favourites[soundName] = true
                saveFavourites()
                Config.Notify("Engine sound added to favourites!", "success")
            else
                Config.Notify("This engine sound is already in your favourites!", "error")
            end
            showEngineSoundMenu()
        elseif selected == 3 then
            -- view favourites
            showFavouritesMenu()
        end
    end
)

RegisterNetEvent(
    "Chroma:EngineSounds:OpenMenu",
    function()
        if not cache.vehicle or cache.seat ~= -1 then
            return Config.Notify("You need to be driving a vehicle to use this!", "error")
        end
        showEngineSoundMenu()
    end
)

AddStateBagChangeHandler(
    "vehdata:sound",
    nil,
    function(bagName, _, value)
        local entity = GetEntityFromStateBagName(bagName)
        if entity == 0 then return end
        if not IsEntityAVehicle(entity) then return end
        ForceUseAudioGameObject(entity, value)
    end
)

lib.addKeybind(
    {
        name = "open_enginesound_menu",
        description = "Open Engine Sound Menu",
        defaultKey = Config.Keybind,
        onPressed = function()
            ExecuteCommand("enginesound")
        end
    }
)

TriggerEvent("chat:addSuggestion", "/enginesound", "Open the Engine Sound Menu!")
