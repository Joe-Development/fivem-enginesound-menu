Config = {
    Keybind = "",                  -- E.G F7 ---> https://docs.fivem.net/docs/game-references/controls/
    MenuPosition = "bottom-right", -- bottom-right, bottom-left, top-right, top-left
    CloseOnSelect = false,         -- Will close the menu when you select an engine sound.
    StoreSoundsByModel = true,    -- This option only applies as a default setting, do you want to (by default) store engine sounds by the model (spawncode)
    Notify = function(msg, type)
        -- customise this notification function to whatever you desire - by default it uses ox_lib but you can edit this
        lib.notify(
            {
                title = "chroma-enginesoundmenu",
                description = msg,
                type = type,
                position = "center-right",
                duration = 6500,
            }
        )
    end,
    EngineSounds = {
        -- Engine Sound Name/Label --> Hash of engine audio (what you'd normally put in vehicles.meta)
        ["Baller"] = "baller",
        ["Adder"] = "adder",
        ["Lazer"] = "lazer"
    }
}
