local UiUtil = {}

-- Desenha uma barra de progresso com contorno, útil para barras de durabilidade ou status.
function UiUtil.drawOutlinedBar(uiElement, x,y, outlineThickness, w, h, f, col)
	local outlineX = x - outlineThickness;
	local outlineY = y - outlineThickness;

	local outlineW = w + (outlineThickness * 2)
	local outlineH = h + (outlineThickness * 2);

	uiElement:drawProgressBar(outlineX, outlineY, outlineW, outlineH, 1, {r=0,g=0,b=0,a=1})
    uiElement:drawProgressBar(x, y, w, h, f, col)
end

-- Faz interpolação de cor entre três cores, útil para gradientes de alerta (ex: verde, laranja, vermelho).
function UiUtil.triLerpColors(value, col1, col2, col3)
    if value <= 0.5 then
        return UiUtil.lerpColors(value * 2, col1, col2);
    else
        return UiUtil.lerpColors((value - 0.5) * 2, col2, col3);
    end
end

-- Faz interpolação linear entre duas cores.
function UiUtil.lerpColors(value, col1, col2)
    return {
        r = UiUtil.lerp(value, col1.r, col2.r),
        g = UiUtil.lerp(value, col1.g, col2.g),
        b = UiUtil.lerp(value, col1.b, col2.b),
        a = UiUtil.lerp(value, col1.a, col2.a)
    }
end

-- Interpolação linear entre dois valores numéricos.
function UiUtil.lerp(value, a, b)
    if value < 0 then value = 0; end
    if value > 1 then value = 1; end

    local diff = b - a;
    return a + (diff * value);
end

-- Configura dados para animação de oscilação em um elemento de UI (ex: botão piscando).
function UiUtil.setupOscillation(uiElement, xPos, delayBetween, conditionFunc)
	uiElement.oscillationData = {
		delta = 0.0,
	    decelerator = 0.96,
	    rate = 0.9,
	    scale = 9,
	    step = 0.0,
	    threshold = 0.2,
	    xPos = xPos,
	    delayBetween = delayBetween,
	    delayTick = 0,
	    conditionFunc = conditionFunc,
	}
	return uiElement.oscillationData;
end

-- Atualiza a animação de oscilação do elemento de UI, para efeitos visuais de alerta.
function UiUtil.updateOscillation(uiElement)
	local data = uiElement.oscillationData;

	local doOscillate = true;
	if data.conditionFunc then
		doOscillate = data.conditionFunc();
	end

	if data.delta > data.threshold then
        local fpsFrac = PerformanceSettings.getLockFPS() / 30.0;
        data.delta = data.delta * data.decelerator;
        data.delta = data.delta - (data.delta * (1 - data.decelerator) / fpsFrac);
        data.step = data.step + data.rate / fpsFrac;
        uiElement:setX(data.xPos + (math.sin(data.step) * data.delta * data.scale));
    else
        data.delta = 0
        data.step = 0;
        uiElement:setX(data.xPos);
    end

    if doOscillate and data.delayBetween == -1 then
    	data.delta = 1;
    end

	if doOscillate and data.delta == 0 then
		data.delayTick = data.delayTick + 1;
		if data.delayTick >= data.delayBetween then
			data.delta = 1;
			data.delayTick = 0;
		end
	end
end

return UiUtil;
