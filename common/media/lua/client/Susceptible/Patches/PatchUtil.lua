local PatchUtil = {}
PatchUtil.patchTable = {}

local function executePatchedCode(patch, ...)
	local ret = patch.original(...);
	for k,v in pairs(patch.methods) do
		ret = v(ret, ...);
	end
	return ret;
end

local function generatePatch(object, methodName)
	if not PatchUtil.patchTable[object] then
		PatchUtil.patchTable[object] = {}
	end

	local patch = {};

	patch.methods = {};
	PatchUtil.patchTable[object][methodName] = patch;

	patch.original = object[methodName];
    object[methodName] = function(...)
    	return executePatchedCode(patch, ...);
	end
end

local function getPatchData(object, methodName)
	if not PatchUtil.patchTable[object] or not PatchUtil.patchTable[object][methodName] then
		generatePatch(object, methodName);
	end
	return PatchUtil.patchTable[object][methodName]
end

function PatchUtil.patchBuiltInMethod(object, methodName, uniqueId, newMethod)
	local patchData = getPatchData(object, methodName);
	patchData.methods[uniqueId] = newMethod;
end

return PatchUtil;
