require "Susceptible/SusceptibleMaskData"
local SusUtil = require "Susceptible/SusceptibleUtil"
local PatchUtil = require "Susceptible/Patches/PatchUtil"

local fgBar = {r=0.0, g=0.6, b=0.0, a=0.7}
local fgText = {r=0.6, g=0.8, b=0.5, a=0.6}

local function drawSuceptibleConditionBar(ret, self, item, y, xoff, yoff, red)
	if not item or not SusUtil.hasSusceptibleDurability(item) then
		return ret;
	end

	local fraction = SusUtil.getNormalizedDurability(item);
	if item:getCondition() <= 0 then
		fraction = 0;
	end

	local top = self.headerHgt + y * self.itemHgt + yoff;

	local textWid = getTextManager():MeasureStringX(self.font, item:getName())
	local xoff2 = 40 + math.max(120, 50 + textWid) + xoff;

	local repairType = SusUtil.getRepairType(item);
	if repairType == SusceptibleRepairTypes.OXYGEN or repairType == SusceptibleRepairTypes.FILTER then
		local filterText;
		local doDrawBar = false;

		if repairType == SusceptibleRepairTypes.OXYGEN then
			local hasOxygen = SusUtil.containsOxygen(item);
			if hasOxygen then
				filterText = getText("UI_Susceptible_Oxygen");
			else
				filterText = getText("UI_Susceptible_No_Oxygen");
			end
			doDrawBar = hasOxygen;
		else
			local hasFilter = SusUtil.containsFilter(item);
			if hasFilter then
				filterText = getText("UI_Susceptible_Filter");
			else
				filterText = getText("UI_Susceptible_No_Filter");
			end
			doDrawBar = hasFilter;
		end
		
		self:drawText(filterText, xoff2, top + (self.itemHgt - self.fontHgt) / 2, fgText.a, fgText.r, fgText.g, fgText.b, self.font)
	
		if doDrawBar then
			textWid = getTextManager():MeasureStringX(self.font, filterText)
			self:drawProgressBar(15 + textWid + xoff2 + xoff, top+(self.itemHgt/2)-1, 100, 2, fraction, fgBar)
		end
	else
		self:drawProgressBar(xoff2, top+(self.itemHgt/2)-1, 100, 2, fraction, fgBar)
	end

	return ret;
end

PatchUtil.patchBuiltInMethod(ISInventoryPane, "drawItemDetails", "Susceptible_conditionBar", drawSuceptibleConditionBar);
