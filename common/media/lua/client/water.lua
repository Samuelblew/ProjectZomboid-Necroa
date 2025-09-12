local WaterGoesBad = {}

-- Função que decide se a água deve ser considerada contaminada
function WaterGoesBad.shouldTaintContainer(object)
    if not object then return false end

    -- Evita afetar water dispensers
    local spriteName = object:getSprite() and object:getSprite():getName()
    if spriteName == "location_business_office_generic_01_49" then
        return false
    end

    return object:hasWater()
        and object.getUsesExternalWaterSource
        and not object:getUsesExternalWaterSource()
end

-- Acesso à classe base de IsoObject
local isoObject = __classmetatables[IsoObject.class].__index

-- Substitui isTaintedWater
local old_isTaintedWater = isoObject.isTaintedWater
isoObject.isTaintedWater = function(self)
    return WaterGoesBad.shouldTaintContainer(self) or (old_isTaintedWater and old_isTaintedWater(self))
end

-- Substitui nome do fluido no UI
local old_getFluidUiName = isoObject.getFluidUiName
isoObject.getFluidUiName = function(self)
    if WaterGoesBad.shouldTaintContainer(self) then
        return Fluid.TaintedWater:getTranslatedName()
    end
    return old_getFluidUiName and old_getFluidUiName(self) or nil
end

-- Transfere como água contaminada
local old_transferFluidTo = isoObject.transferFluidTo
isoObject.transferFluidTo = function(self, fluidContainer, amount)
    local amountTransfered = old_transferFluidTo and old_transferFluidTo(self, fluidContainer, amount) or 0
    if WaterGoesBad.shouldTaintContainer(self) then
        fluidContainer:adjustSpecificFluidAmount(Fluid.Water, fluidContainer:getSpecificFluidAmount(Fluid.Water) - amountTransfered)
        fluidContainer:addFluid(FluidType.TaintedWater, amountTransfered)
    end
    return amountTransfered
end

-- Beber direto: transforma temporariamente em contaminada
local old_moveFluidToTemporaryContainer = isoObject.moveFluidToTemporaryContainer
isoObject.moveFluidToTemporaryContainer = function(self, amount)
    local tempContainer = old_moveFluidToTemporaryContainer and old_moveFluidToTemporaryContainer(self, amount)
    if tempContainer and WaterGoesBad.shouldTaintContainer(self) then
        local waterAmount = tempContainer:getSpecificFluidAmount(Fluid.Water)
        tempContainer:adjustSpecificFluidAmount(Fluid.Water, 0)
        tempContainer:addFluid(FluidType.TaintedWater, waterAmount)
    end
    return tempContainer
end

-- (Mantido apenas por completude – pode ser removido)
local old_getFluidAmount = isoObject.getFluidAmount
isoObject.getFluidAmount = function(self)
    return old_getFluidAmount and old_getFluidAmount(self) or 0
end

-- Pode ser usado para forçar alguma atualização ao abrir o menu de beber (não obrigatório)
Events.OnFillWorldObjectContextMenu.Add(function(playerNum, context, worldObjects, test)
    for i = 1, context.subOptionNums do
        local childContext = context:getSubMenu(i)
        for j = 1, #childContext.options do
            local option = childContext.options[j]
            if option.name == getText("ContextMenu_Drink") and instanceof(option.param3, "IsoObject") then
                -- Forçar algum update se necessário
            end
        end
    end
end)

-- Apenas verifica recipientes de água válidos
local function IsWaterContainer(object)
    return object 
        and object.hasWater and object:hasWater()
        and object.getUsesExternalWaterSource 
        and not object:getUsesExternalWaterSource()
end

-- Ao carregar cada quadrado do mundo
local function ModifyWater(square)
    if not square then return end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if IsWaterContainer(obj) then
            -- Nada é esvaziado ou alterado aqui — só reconhecido
        end
    end
end

Events.LoadGridsquare.Add(ModifyWater)


