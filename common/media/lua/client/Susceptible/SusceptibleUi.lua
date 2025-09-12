local UiUtil = require 'Susceptible/UiUtil'
local SusUtil = require 'Susceptible/SusceptibleUtil'

-- Classe responsável pela interface gráfica do mod Susceptible, derivada de ISPanel.
SusceptibleUi = ISPanel:derive("SusceptibleUi");

local GREY = {r=1, g=1, b=1, a=1}
local ORANGE = {r=1, g=1, b=0, a=1}
local RED = {r=1, g=0, b=0, a=1}

local OSCILLATION_DELAY = 12;
local MASK_BUTTON_X = 11

-- Renderiza a interface do painel, incluindo barra de durabilidade e efeitos visuais.
function SusceptibleUi:render()
	if self:isMouseOver() then
		self:drawRect(self:getWidth() - 12, 0, 12, 12, 0.5, 1, 1, 1);
	end

	if self.hasMask then
		UiUtil.drawOutlinedBar(self, 8, 50, 2, 38, 6, self.maskDurability, {r=0.6,g=1,b=0.6,a=1});
        UiUtil.updateOscillation(self.maskButton);
    else
        self.maskButton:setX(MASK_BUTTON_X);
        self.maskButton.oscillationData.delta = 0;
	end
end

-- Placeholder para clique em opções (pode ser expandido para interações futuras).
function SusceptibleUi:onOptionMouseDown(button, x, y)
end

-- Gerencia o evento de soltar o mouse, salvando a posição da interface se estiver sendo movida.
function SusceptibleUi:onMouseUp(x,y)
	if self.moving and self.playerNum == 0 then
		SusUtil.saveUiOffsets(self.x, self.y);
		SusceptibleMod.applyUiOffsets();
	end
	ISPanel.onMouseUp(self, x, y);
end

-- Atualiza o ícone da máscara exibido na interface, dependendo do estado do item e ameaça.
function SusceptibleUi:updateMaskImage(item, maskInfo, threatValue, isBroken)
	if threatValue > 1 then
		self.maskButton:setImage(self.virusTex);
	elseif item then
		if maskInfo.repairType == SusceptibleRepairTypes.OXYGEN then
			if isBroken then
				self.maskButton:setImage(self.noOxygenIcon);
			else
				self.maskButton:setImage(self.oxygenIcon);
			end
		elseif isBroken then
			self.maskButton:setImage(self.maskIconOff);
		else
			self.maskButton:setImage(item:getTex());
		end
	else
		self.maskButton:setImage(self.maskIconOff);
    end
end

-- Atualiza informações de durabilidade e cor de fundo da interface conforme o nível de ameaça.
function SusceptibleUi:updateMaskInfo(hasMask, maskDurability, threatValue)
	self.maskDurability = maskDurability;
	self.hasMask = hasMask;
	local col = UiUtil.triLerpColors(threatValue, GREY, ORANGE, RED);
	self.maskBg:setColor(col.r, col.g, col.b);
end

-- Construtor da interface, inicializa propriedades e texturas.
function SusceptibleUi:new (x, y, playerNum)
	local o = {}
	o = ISPanel:new(x, y, 64, 64);
	setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
    o.backgroundColor = {r=0, g=0, b=0, a=0};
    o.anchorLeft = true;
    o.playerNum = playerNum;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.moveWithMouse = true;
	o.backgroundTex = getTexture("media/ui/HandMain2_Off.png");
	o.maskIconOff = getTexture("media/ui/Susceptible/maskoff.png");
	o.oxygenIcon = getTexture("media/ui/Susceptible/tank.png");
	o.noOxygenIcon = getTexture("media/ui/Susceptible/notank.png");
	o.virusTex = getTexture("media/ui/Susceptible/virus.png");

	o.maskDurability = 0.0;
    o.oscillationTick = 0;

    SusceptibleUi.instance = o;
	return o;
end

-- Destroi a interface, removendo todos os elementos e fechando o painel.
function SusceptibleUi:destroyUi()
    self:clearChildren();
    self:close();
    self:removeFromUIManager();
end

-- Inicializa os elementos visuais da interface, como fundo, botão e eventos de clique.
function SusceptibleUi:initialise()
	ISPanel.initialise(self);

    self.maskBg = ISImage:new(4, 0, self.backgroundTex:getWidthOrig(), self.backgroundTex:getHeightOrig(), self.backgroundTex);
    self.maskBg:initialise();
    self.maskBg.parent = self;
    self:addChild(self.maskBg);

	self.maskButton = ISButton:new(MASK_BUTTON_X, 7, 32, 32, "", self, SusceptibleUi.onOptionMouseDown);
    self.maskButton:setImage(self.maskIcon);
    self.maskButton.internal = "MASK";
    self.maskButton:initialise();
    self.maskButton:instantiate();
    self.maskButton:setDisplayBackground(false);

	local this = self
	self.maskButton.onRightMouseUp = function(self, x, y)
		local player = getSpecificPlayer(this.playerNum);
		local mask = SusceptibleMod.getEquippedMaskItemAndData(player);
		local menu = nil
		if mask then
			menu = ISInventoryPaneContextMenu.createMenu(this.playerNum, true, {mask}, self:getAbsoluteX()+x, self:getAbsoluteY()+y);
			menu:addOptionOnTop(getText("___________"));
		else
			menu = ISContextMenu.get(this.playerNum, self:getAbsoluteX()+x, self:getAbsoluteY()+y);
		end

		local allMasks = SusceptibleMod.getAllMaskItems(player);
		table.sort(allMasks, function(a, b) return SusUtil.getNormalizedDurability(a) < SusUtil.getNormalizedDurability(b) end)


		local equippedMasks = {};
		for _, item in ipairs(allMasks) do
			local name = item:getDisplayName();
			local durability = math.floor(SusUtil.getNormalizedDurability(item) * 100);

			if player:isEquippedClothing(item) then
				table.insert(equippedMasks, item);
			else
				menu:addOptionOnTop(name.." - "..durability.."%", {item}, ISInventoryPaneContextMenu.onWearItems, this.playerNum);
			end
		end

		for _, item in ipairs(equippedMasks) do
			if item ~= mask then
				local name = item:getDisplayName();
				local durability = math.floor(SusUtil.getNormalizedDurability(item) * 100);
				menu:addOptionOnTop("[ "..name.." - "..durability.."% ]", item, SusUtil.setAsPriorityMask, this.playerNum);
			end
		end

		if mask then
			local mName = mask:getDisplayName();
			local mDurability = math.floor(SusUtil.getNormalizedDurability(mask) * 100);
			menu:addOptionOnTop("-[ "..mName.." - "..mDurability.."% ]-", mask, SusUtil.setAsPriorityMask, this.playerNum);
		end
	end

    local oscillateCondition = function() 
            return self.maskDurability <= 0.2; 
        end;

    UiUtil.setupOscillation(self.maskButton, MASK_BUTTON_X, OSCILLATION_DELAY, oscillateCondition);

    self.maskButton.borderColor = {r=1, g=1, b=1, a=0.1};
    self.maskButton:ignoreWidthChange();
    self.maskButton:ignoreHeightChange();
	self:addChild(self.maskButton); 
end
