if not PZAPI then require("PZAPI") end

local config = {}
local listeners = {}

config._listeners = listeners

local options = PZAPI.ModOptions:create("TestComboSafe", "ComboBox Seguro")

-- Adiciona um combo box
options:addComboBox("FavoriteColor", "Cor Favorita", "Escolha uma cor:")

local combo = options:getOption("FavoriteColor")
combo:addItem("Vermelho", false)
combo:addItem("Verde", false)
combo:addItem("Azul", true) -- default
combo:addItem("Roxo", false)

-- Coleta os valores no apply
options.apply = function(self)
    for k, v in pairs(self.dict) do
        config[k] = v:getValue()
    end
    for _, cb in ipairs(listeners) do
        cb()
    end
end

-- Auto apply ao entrar no menu
Events.OnMainMenuEnter.Add(function()
    options:apply()
end)

function config.onApply(fn)
    table.insert(listeners, fn)
end

return config
