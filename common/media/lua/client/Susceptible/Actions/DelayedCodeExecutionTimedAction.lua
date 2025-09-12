require "TimedActions/ISBaseTimedAction"

local DelayedCodeExecutionTimedAction = ISBaseTimedAction:derive("DelayedCodeExecutionTimedAction")

function DelayedCodeExecutionTimedAction:isValid()
	return true;
end

function DelayedCodeExecutionTimedAction:start()
	if self.onStartFunc then
        self.onStartFunc(self)
    end
end

function DelayedCodeExecutionTimedAction:perform()
	ISBaseTimedAction.perform(self);
	if self.lambda then
        self.lambda(self);
    end
end

function DelayedCodeExecutionTimedAction:setOnStart(func)
	self.onStartFunc = func;
end

function DelayedCodeExecutionTimedAction:new(character, lambda, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.stopOnRun = false;
	o.character = character
	o.lambda = lambda

	if not time then
		time = -1;
	end

	o.maxTime = time
	return o
end

return DelayedCodeExecutionTimedAction;
