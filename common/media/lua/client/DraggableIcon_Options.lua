if not PZAPI then require("PZAPI") end

local config = {}
local listeners = {}

-- Expose listeners so external scripts can call them
config._listeners = listeners

-- Mod options page
local options = PZAPI.ModOptions:create("DraggableIcon", "Draggable Icon")

-- Icon size slider (range: 32 to 128, step: 1, default: 46)
options:addSlider(
    "IconSize",
    "Icon Size",
    32, 128, 1, 46,
    "Adjust the icon size."
)


-- Apply function for ModOptions
options.apply = function(self)
    for k, v in pairs(self.dict) do
        config[k] = v:getValue()
    end
    for _, cb in ipairs(listeners) do
        cb()
    end
end

-- Auto-apply on main menu load
Events.OnMainMenuEnter.Add(function()
    options:apply()
end)

-- Let external scripts register callbacks
function config.onApply(fn)
    table.insert(listeners, fn)
end

return config
