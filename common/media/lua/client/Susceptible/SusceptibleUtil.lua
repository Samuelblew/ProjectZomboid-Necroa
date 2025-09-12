require "Susceptible/SusceptibleMaskData"

-- Define constantes para os itens especiais usados em máscaras.
local Oxygen_Tank_ITEM = "Base.Oxygen_Tank";
local FILTER_ITEM = "Base.GasmaskFilter";

-- Tabela utilitária principal do mod, com funções auxiliares para manipulação de máscaras e durabilidade.
local SusceptibleUtil = {}

-- Tabela de itens que possuem durabilidade especial.
local durabilityItems = {
	GasmaskFilter = true,
	Oxygen_Tank = true,
}

-- Verifica se o item possui durabilidade controlada pelo mod.
function SusceptibleUtil.hasSusceptibleDurability(item)
	local itemType = item:getType();
	return SusceptibleMaskItems:getMaskData(item) or durabilityItems[itemType];
end

-- Inicializa os dados de modData para um item de máscara.
local function initializeModData(item, modData)
	modData.susceptibleData = {}

	local maxDurability = 1;

	local itemType = item:getType();
	local maskInfo = SusceptibleMaskItems:getMaskData(item)
	if maskInfo then
		maxDurability = maskInfo.durability;
	end

    modData.susceptibleData.durabilityMax = maxDurability;
    modData.susceptibleData.durability = maxDurability;

    -- Importa durabilidade antiga se disponível
    if modData.filterDurability then
    	modData.susceptibleData.durability = modData.filterDurability;
    end

    modData.susceptibleData.weights = {}

    if maskInfo and maskInfo.repairType == SusceptibleRepairTypes.FILTER then
    	SusceptibleUtil.setWeightChange(item, "filter", 0.5);
	end
end

-- Retorna (e inicializa se necessário) os dados de modData do item.
function SusceptibleUtil.getItemModData(item)
	local modData = item:getModData();
	if not modData.susceptibleData then
		initializeModData(item, modData);
	end
    return modData.susceptibleData;
end

-- Aplica dano à durabilidade do item e atualiza o peso.
function SusceptibleUtil.damageDurability(item, damage)
    local data = SusceptibleUtil.getItemModData(item);

    data.durability = data.durability - damage;
    if data.durability < 0 then
        data.durability = 0;
    end

    SusceptibleUtil.updateWeight(item);
end

-- Retorna a durabilidade normalizada (0 a 1) do item.
function SusceptibleUtil.getNormalizedDurability(item)
	local durability = 1;
	local modData = item:getModData().susceptibleData
	if modData then
		durability = modData.durability / modData.durabilityMax;
	end
	return durability;
end

-- Verifica se o item está quebrado (condição zero ou sem tanque/filtro).
function SusceptibleUtil.isBroken(item)
	if item:getCondition() <= 0 then
		return true;
	end

	local data = SusceptibleUtil.getItemModData(item);

	local maskInfo = SusceptibleMaskItems:getMaskData(item);
	if not maskInfo or maskInfo.repairType == SusceptibleRepairTypes.OXYGEN and not data.hasOxygen_Tank then 
		return true;
	end
	
    if data.durabilityMax then
    	return data.durability <= 0;
    end
    return false;
end

-- Retorna o tipo de reparo da máscara.
function SusceptibleUtil.getRepairType(item)
	local maskInfo = SusceptibleMaskItems:getMaskData(item);
	if not maskInfo then
		return nil;
	elseif not maskInfo.repairType then
		return SusceptibleRepairTypes.DEFAULT;
	else
		return maskInfo.repairType;
	end
end

-- Insere um filtro em uma máscara, transferindo durabilidade e removendo o item do inventário.
function SusceptibleUtil.insertFilter(maskItem, filterItem, player)
	local maskData = SusceptibleUtil.getItemModData(maskItem);
	if not maskData.removedFilter then
		return
	end

	SusceptibleUtil.overwriteDurability(filterItem, maskItem);
	SusceptibleUtil.setWeightChange(maskItem, "filter", 0.5);

	maskData.removedFilter = false;
	player:getInventory():DoRemoveItem(filterItem);
end

-- Remove o filtro da máscara, transferindo durabilidade para o novo filtro e adicionando ao inventário.
function SusceptibleUtil.removeFilter(maskItem, player)
	local maskData = SusceptibleUtil.getItemModData(maskItem)
	if maskData.removedFilter then
		return;
	end

	local filterItem = player:getInventory():AddItem(FILTER_ITEM);
	SusceptibleUtil.overwriteDurability(maskItem, filterItem);
	SusceptibleUtil.setWeightChange(maskItem, "filter", 0);
	
	maskData.removedFilter = true;
end

-- Insere um tanque de oxigênio na máscara, transferindo durabilidade e removendo o item do inventário.
function SusceptibleUtil.insertOxygen(mask, oxygen, player)
	local maskData = SusceptibleUtil.getItemModData(mask);
	if maskData.hasOxygen_Tank then
		return;
	end

	SusceptibleUtil.overwriteDurability(oxygen, mask);
	local weight = SusceptibleUtil.calculateOxygen_TankWeight(SusceptibleUtil.getNormalizedDurability(mask));
	SusceptibleUtil.setWeightChange(mask, "Oxygen_Tank", weight);

	maskData.hasOxygen_Tank = true;
	player:getInventory():DoRemoveItem(oxygen);
end

-- Remove o tanque de oxigênio da máscara, transferindo durabilidade para o novo tanque e adicionando ao inventário.
function SusceptibleUtil.removeOxygen(mask, player)
	local maskData = SusceptibleUtil.getItemModData(mask)
	if not maskData.hasOxygen_Tank then
		return;
	end

	local oxygenItem = player:getInventory():AddItem(Oxygen_Tank_ITEM);

	SusceptibleUtil.overwriteDurability(mask, oxygenItem);
	SusceptibleUtil.setWeightChange(mask, "Oxygen_Tank", 0);

	local durability = SusceptibleUtil.getNormalizedDurability(oxygenItem);
	SusceptibleUtil.setWeightChange(oxygenItem, "Oxygen_Tank", (1-durability) * -3);

	maskData.hasOxygen_Tank = false;
end

-- Verifica se o item é um filtro de máscara.
function SusceptibleUtil.isFilter(item)
	return item:getType() == "GasmaskFilter";
end

-- Verifica se o item é um tanque de oxigênio.
function SusceptibleUtil.isOxygen(item)
	return item:getType() == "Oxygen_Tank";
end

-- Verifica se o item é água sanitária.
function SusceptibleUtil.isBleach(item)
	return item:getType() == "Bleach";
end

-- Verifica se o item é uma máscara de pano lavável e não está quebrada.
function SusceptibleUtil.isClothMask(item)
	local maskInfo = SusceptibleMaskItems:getMaskData(item);
	return maskInfo and maskInfo.repairType == SusceptibleRepairTypes.WASH and not SusceptibleUtil.isBroken(item);
end

-- Encontra todos os filtros no inventário.
function SusceptibleUtil.findAllFilters(inventory)
	local filtersOut = ArrayList.new();
	inventory:getAllEval(SusceptibleUtil.isFilter, filtersOut);
	return filtersOut;
end

-- Encontra todos os tanques de oxigênio no inventário.
function SusceptibleUtil.findAllOxygen(inventory)
	local oxygenOut = ArrayList.new();
	inventory:getAllEval(SusceptibleUtil.isOxygen, oxygenOut);
	return oxygenOut;
end

-- Encontra todas as máscaras de pano laváveis no inventário.
function SusceptibleUtil.findAllClothMasks(inventory)
	local masksOut = ArrayList.new();
	inventory:getAllEval(SusceptibleUtil.isClothMask, masksOut);
	return masksOut;
end

-- Encontra todos os itens de limpeza (sabão, líquido de limpeza) no inventário.
function SusceptibleUtil.findAllCleaningSupplies(inventory)
	local cleanerOut = ArrayList.new();
	cleanerOut:addAll(inventory:getItemsFromType("Soap2", true))
    cleanerOut:addAll(inventory:getItemsFromType("CleaningLiquid2", true))
	return cleanerOut;
end

-- Encontra toda água sanitária no inventário.
function SusceptibleUtil.findAllBleach(inventory)
	local cleanerOut = ArrayList.new();
	inventory:getAllEval(SusceptibleUtil.isBleach, cleanerOut);
	return cleanerOut;
end

-- Verifica se a máscara contém filtro.
function SusceptibleUtil.containsFilter(maskItem)
	local data = maskItem:getModData().susceptibleData;
	return not data or not data.removedFilter;
end

-- Verifica se a máscara contém tanque de oxigênio.
function SusceptibleUtil.containsOxygen(maskItem)
	local data = maskItem:getModData().susceptibleData;
	return data and data.hasOxygen_Tank;
end

-- Transfere a durabilidade de um item para outro, zerando o item de origem.
function SusceptibleUtil.overwriteDurability(fromItem, toItem)
	local fromData = SusceptibleUtil.getItemModData(fromItem)
	local outPercent = fromData.durability / fromData.durabilityMax;
	fromData.durability = 0;

	local toData = SusceptibleUtil.getItemModData(toItem);
	toData.durability = outPercent * toData.durabilityMax;
end

-- Adiciona parte da durabilidade de um item a outro, multiplicando pelo fator mult.
function SusceptibleUtil.addDurabilityFrom(fromItem, toItem, mult)
	local fromData = SusceptibleUtil.getItemModData(fromItem)
	local outPercent = mult * fromData.durability / fromData.durabilityMax;
	fromData.durability = 0;

	local toData = SusceptibleUtil.getItemModData(toItem);
	toData.durability = (outPercent * toData.durabilityMax) + toData.durability;
	if toData.durability > toData.durabilityMax then
		toData.durability = toData.durabilityMax;
	end
end

-- Repara um item usando outro, transferindo durabilidade e removendo o item de reparo do inventário.
function SusceptibleUtil.repairWith(itemToRepair, repairItem, repairMult, player)
	SusceptibleUtil.addDurabilityFrom(repairItem, itemToRepair, repairMult);
	player:getInventory():DoRemoveItem(repairItem);
end

-- Repara um item em uma porcentagem da durabilidade máxima.
function SusceptibleUtil.repair(item, repairPercentage)
	local data = SusceptibleUtil.getItemModData(item);
	data.durability = data.durability + (data.durabilityMax * repairPercentage);
	if data.durability > data.durabilityMax then
		data.durability = data.durabilityMax;
	end
end

-- Calcula o peso do tanque de oxigênio baseado na durabilidade restante.
function SusceptibleUtil.calculateOxygen_TankWeight(durability)
	local variableWeight = 3;
	return 2 + (variableWeight * durability);
end

-- Atualiza o peso do item de acordo com o tipo de máscara e tanque.
function SusceptibleUtil.updateWeight(item)
	local maskInfo = SusceptibleMaskItems:getMaskData(item);
	if not maskInfo then
		return;
	end

	if maskInfo.repairType == SusceptibleRepairTypes.OXYGEN then
		local modData = SusceptibleUtil.getItemModData(item);
		if modData.hasOxygen_Tank then
			local weight = SusceptibleUtil.calculateOxygen_TankWeight(SusceptibleUtil.getNormalizedDurability(item))
			SusceptibleUtil.setWeightChange(item, "Oxygen_Tank", weight);
		end
	end
end

-- Altera o peso do item dinamicamente, controlando por chave.
function SusceptibleUtil.setWeightChange(item, key, amount)
	local data = SusceptibleUtil.getItemModData(item);

	local change = amount;
	if data.weights[key] then
		change = amount - data.weights[key];
	end

	data.weights[key] = amount;
	item:setActualWeight(item:getActualWeight() + change);
	item:setCustomWeight(true);
end

-- Retorna o tipo de tela dividida (split screen) atual.
function SusceptibleUtil.getSplitScreenType()
	local players = IsoPlayer.getPlayers();
	if players:get(1) ~= nil and players:get(2) ~= nil then
		return "CROSS";
	elseif players:get(1) ~= nil then
		return "VERTICAL";
	else
		return "NONE";
	end
end

-- Salva os deslocamentos da interface do usuário (UI) para cada tipo de tela dividida.
function SusceptibleUtil.saveUiOffsets(x, y)
	local splitScreenType = SusceptibleUtil.getSplitScreenType();
	if splitScreenType == "CROSS" or splitScreenType == "VERTICAL" then
		x = x * 2.0;
	end
	if splitScreenType == "CROSS" then
		y = y * 2.0;
	end

	local data = ModData.getOrCreate("SusceptibleUiOffsets");
	data.susceptibleUiX = x;
	data.susceptibleUiY = y;
end

-- Carrega os deslocamentos da interface do usuário (UI), garantindo que fiquem dentro da tela.
function SusceptibleUtil.loadUiOffsets()
	local BASE_UI_SIZE = 64;

	local data = ModData.getOrCreate("SusceptibleUiOffsets");
    local x = data.susceptibleUiX;
    local y = data.susceptibleUiY;
    if not x or not y then
    	x = 60;
    	y = 10;
    end

    local width = getCore():getScreenWidth();
    local height = getCore():getScreenHeight();

    if x + BASE_UI_SIZE > width then x = width - BASE_UI_SIZE end
    if y + BASE_UI_SIZE > height then y = height - BASE_UI_SIZE end

    return x, y;
end

-- Define uma máscara como prioritária para o jogador.
function SusceptibleUtil.setAsPriorityMask(maskItem, playerNum)
	local player = getSpecificPlayer(playerNum);
	local modData = player:getModData();
	modData.susceptiblePriorityMask = maskItem:getID();
end

-- Retorna o ID da máscara prioritária do jogador.
function SusceptibleUtil.getPriorityMaskID(player)
	local modData = player:getModData();
	return modData.susceptiblePriorityMask;
end

return SusceptibleUtil;
