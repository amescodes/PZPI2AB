local old_ISTakeEngineParts_perform = ISTakeEngineParts.perform
function ISTakeEngineParts:perform()
	old_ISTakeEngineParts_perform(self)
-- 	ISBaseTimedAction.perform(self)
-- 	self.item:setJobDelta(0)
-- 	local cond = self.part:getCondition();
-- 	local skill = self.character:getPerkLevel(Perks.Mechanics) - self.vehicle:getScript():getEngineRepairLevel();
-- 	local condForPart = math.max(20 - (skill), 5);
-- 	local args = { vehicle = self.vehicle:getId(), skillLevel = skill }
-- 	sendClientCommand(self.character, 'vehicle', 'takeEngineParts', args)

-- 	if not self.character:getMechanicsItem(self.vehicle:getMechanicalID() .. "3") then
-- --		print("add exp", math.floor(cond / condForPart)/2)
-- 		self.character:getXp():AddXP(Perks.Mechanics, math.floor(cond / condForPart)/2);
-- 	end
-- 	self.character:addMechanicsItem(self.vehicle:getMechanicalID() .. "3", self.part, getGameTime():getCalender():getTimeInMillis());
    
	-- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end
end

function ISTakeEngineParts:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end