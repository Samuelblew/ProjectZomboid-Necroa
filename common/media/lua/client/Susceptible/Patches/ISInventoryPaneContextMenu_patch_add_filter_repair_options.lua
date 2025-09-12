local SusUtil = require "Susceptible/SusceptibleUtil"
local PatchUtil = require "Susceptible/Patches/PatchUtil"
local DelayedAction = require "Susceptible/Actions/DelayedCodeExecutionTimedAction"

local MAX_BLEACH_USES = 20

local function getConditionPercent(item)
	local cond = SusUtil.getNormalizedDurability(item);
	cond = math.floor(cond * 100);
	return cond.."%";
end

local function createDelayedAction(player, func)
	return DelayedAction:new(player, func, 120);
end

local animateHead = function(action)
	action:setActionAnim("WearClothing");
	action:setAnimVariable("WearClothingLocation", "Face")
end

local animateBody = function(action)
	action:setActionAnim("WearClothing");
	action:setAnimVariable("WearClothingLocation", "Waist")
end

local animateHands = function(action)
	action:setActionAnim("EquipItem");
end

local function addRemoveFilter(mask, filter, player)
	if SusUtil.containsFilter(mask) then
		SusUtil.removeFilter(mask, player);
	end
	if filter then
		SusUtil.insertFilter(mask, filter, player);
	end
end

local function addRemoveFilterDelayed(mask, filter, player)
	local delayedAction = DelayedAction:new(player, function(action) addRemoveFilter(mask, filter, player) end, 120);
	delayedAction:setOnStart(animateHead);
	ISTimedActionQueue.add(delayedAction);
end

local function addRemoveOxygen(mask, oxygen, player)
	if SusUtil.containsOxygen(mask) then
		SusUtil.removeOxygen(mask, player);
	end
	if oxygen then
		SusUtil.insertOxygen(mask, oxygen, player);
	end
end

local function addRemoveOxygenDelayed(mask, oxygen, player)
	local delayedAction = DelayedAction:new(player, function(action) addRemoveOxygen(mask, oxygen, player) end, 120);
	delayedAction:setOnStart(animateBody);
	ISTimedActionQueue.add(delayedAction);
end

local function repairWithClothMask(fullMask, clothMask, player)
	SusUtil.repairWith(fullMask, clothMask, 1/3, player);
end

local function repairWithClothMaskDelayed(mask, clothMask, player)
	local delayedAction = DelayedAction:new(player, function(action) repairWithClothMask(mask, clothMask, player) end, 120);
	if mask:isEquipped() then
		delayedAction:setOnStart(animateHead);
	else
		delayedAction:setOnStart(animateHands);
	end
	ISTimedActionQueue.add(delayedAction);
end

local function repairWithBleach(mask, bleach, player)
	SusUtil.repair(mask, 1);

	local bleachData = bleach:getModData();
	if bleachData.useCount + 1 >= MAX_BLEACH_USES then
		bleach:Use();
	else
		bleachData.useCount = bleachData.useCount + 1;
	end

	mask:setCondition(mask:getCondition() - 1);

	if mask:isEquipped() then
		local body = player:getBodyDamage();
		body:setPoisonLevel(math.min(body:getPoisonLevel() + 25, 35));
	end
end

local function repairWithBleachDelayed(mask, bleach, player)
	local delayedAction = DelayedAction:new(player, function(action) repairWithBleach(mask, bleach, player) end, 120);
	if mask:isEquipped() then
		delayedAction:setOnStart(animateHead);
	else
		delayedAction:setOnStart(animateHands);
	end
	ISTimedActionQueue.add(delayedAction);
end






local function addRepairOptions(context, player, isInPlayerInventory, items, x, y, origin)
	if not context or not isInPlayerInventory or #items ~= 1 then
		return context;
	end

	local item = items[1]
    if not instanceof(item, "InventoryItem") then
        if #item.items == 2 then
            item = item.items[1];
        else
        	return context
        end
    end

    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

	local repairType = SusUtil.getRepairType(item);
	if not repairType or repairType == SusceptibleRepairTypes.NONE or item:getCondition() <= 0 then
		return context;
	end

	local durability = SusUtil.getNormalizedDurability(item);

	if repairType == SusceptibleRepairTypes.CLOTH and durability < 0.975 then

		local cloths = SusUtil.findAllClothMasks(playerInv);
		if cloths:size() > 0 then
			local option = context:addOption(getText("UI_Susceptible_Repair_With"))
			local subMenu = context:getNew(context)
			context:addSubMenu(option, subMenu)

			for i=1,cloths:size() do
				local cloth = cloths:get(i-1);
				local loss = " ";

				local repairVal = SusUtil.getNormalizedDurability(cloth) * 0.33333;
				if repairVal > 1 - durability then
					local lossNum = math.floor((repairVal - (1-durability)) * 100);
					loss = "   (-"..lossNum.."%)";
				end

				local repairPercent = math.floor(repairVal * 100.0).."%";
				subMenu:addOption(cloth:getDisplayName()..":  "..repairPercent..loss, item, repairWithClothMaskDelayed, cloth, playerObj);
			end
		end

	elseif repairType == SusceptibleRepairTypes.WASH and durability < 0.975 then
		local bleach = SusUtil.findAllBleach(playerInv);
		if bleach:size() > 0 then
			local mostUsed = nil;
			local mostUsedVal = -1;
			for i=1,bleach:size() do
				local ble = bleach:get(i-1);
				local data = ble:getModData();
				if not data.useCount then
					data.useCount = 0;
				end

				if data.useCount > mostUsedVal then
					mostUsed = ble;
					mostUsedVal = data.useCount;
				end
			end

			context:addOption(getText("UI_Susceptible_Bleach_Repair").."  ("..(MAX_BLEACH_USES - mostUsedVal).."/"..MAX_BLEACH_USES..")", item, repairWithBleachDelayed, mostUsed, playerObj);
		end

	elseif repairType == SusceptibleRepairTypes.FILTER then
    	local hasFilter = SusUtil.containsFilter(item);
    	local optionText = getText("UI_Susceptible_Swap_Filter");
		if not hasFilter then
			optionText = getText("UI_Susceptible_Insert_Filter");
		end

		local filters = SusUtil.findAllFilters(playerInv);
		if filters:size() > 0 then
			local option = context:addOption(optionText)
			local subMenu = context:getNew(context)
			context:addSubMenu(option, subMenu)

			for i=1,filters:size() do
				local filter = filters:get(i-1);
				subMenu:addOption(getText("UI_Susceptible_Filter").." - "..getConditionPercent(filter), item, addRemoveFilterDelayed, filter, playerObj);
			end
		end

		if hasFilter then
			context:addOption(getText("UI_Susceptible_Remove_Filter"), item, addRemoveFilterDelayed, nil, playerObj);
		end
	elseif repairType == SusceptibleRepairTypes.OXYGEN then
    	local hasOxygen = SusUtil.containsOxygen(item);
		local optionText = getText("UI_Susceptible_Swap_Oxygen");
		if not hasOxygen then
			optionText = getText("UI_Susceptible_Insert_Oxygen");
		end

		local Oxygen_Tanks = SusUtil.findAllOxygen(playerInv);
		if Oxygen_Tanks:size() > 0 then
			local option = context:addOption(optionText)
			local subMenu = context:getNew(context)
			context:addSubMenu(option, subMenu)

			for i=1,Oxygen_Tanks:size() do
				local tank = Oxygen_Tanks:get(i-1);
				subMenu:addOption(getText("UI_Susceptible_Oxygen").." - "..getConditionPercent(tank), item, addRemoveOxygenDelayed, tank, playerObj);
			end
		end

		if hasOxygen then
			context:addOption(getText("UI_Susceptible_Remove_Oxygen"), item, addRemoveOxygenDelayed, nil, playerObj);
		end
	end

	return context;
end

PatchUtil.patchBuiltInMethod(ISInventoryPaneContextMenu, "createMenu", "Susceptible_addRepairOptions", addRepairOptions);
