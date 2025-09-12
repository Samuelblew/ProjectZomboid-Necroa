local function initSusceptibleTrait()
    TraitFactory.addTrait("Susceptible", getText("UI_trait_Susceptible"), 0, getText("UI_trait_SusceptibleDesc"), false, true);
end

Events.OnGameBoot.Add(initSusceptibleTrait);