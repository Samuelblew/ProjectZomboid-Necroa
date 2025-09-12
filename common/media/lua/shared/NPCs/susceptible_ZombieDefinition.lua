require 'NPCs/ZombiesZoneDefinition'

local spawnChance = SandboxVars.Susceptible.SpawnChance;

table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleHazmat",                  chance = spawnChance * 0.01});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleMilitaryNBC",             chance = spawnChance * 0.01});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleMilitaryGasmask",         chance = spawnChance * 0.02});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptiblePoliceGasmask",           chance = spawnChance * 0.03});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleFirefighter",             chance = spawnChance * 0.03});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleMilitaryHighcommand",     chance = spawnChance * 0.05});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleSurvivorAdvanced",        chance = spawnChance * 0.04});
table.insert(ZombiesZoneDefinition.Default, {name = "SusceptibleSurvivorBasic",           chance = spawnChance * 0.06});