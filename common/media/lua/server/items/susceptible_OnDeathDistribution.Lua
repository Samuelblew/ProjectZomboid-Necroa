local outfitToItemMap = {
	SusceptibleHazmat = "Base.Oxygen_Tank",
	SusceptibleFirefighter = "Base.Oxygen_Tank",

	SusceptibleMilitaryGasmask = "Base.GasmaskFilter",
	SusceptibleMilitaryNBC = "Base.GasmaskFilter",
	SusceptiblePoliceGasmask = "Base.GasmaskFilter",
};

local function rollToAddLoot(item, inventory)
	local lootchance = SandboxVars.Susceptible.LootChance;
	if lootchance >= ZombRand(1, 100) then
		inventory:AddItems(item, 1);
	end
end

local function checkDrops(zombie)
	if not zombie:getOutfitName() then return end

	local outfit = tostring(zombie:getOutfitName());
	local item = outfitToItemMap[outfit];
	if item then
		rollToAddLoot(item, zombie:getInventory());
	end
end

Events.OnZombieDead.Add(checkDrops);