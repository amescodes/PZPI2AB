
local old_ISRemoveBurntVehicle_perform = ISRemoveBurntVehicle.perform
function ISRemoveBurntVehicle:perform()
    old_ISRemoveBurntVehicle_perform(self)
	-- if self.sound ~= 0 then
	-- 	self.character:getEmitter():stopSound(self.sound)
	-- end
	-- local totalXp = 5;
	-- for i=1,math.max(5,self.character:getPerkLevel(Perks.MetalWelding)) do
	-- 	if self:checkAddItem("MetalBar", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalBar", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalBar", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalBar", 15) then totalXp = totalXp + 2 end; -- additional yield on account of fixing propane torches not draining
	-- 	if self:checkAddItem("MetalPipe", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalPipe", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalPipe", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("MetalPipe", 15) then totalXp = totalXp + 2 end; -- additional yield on account of fixing propane torches not draining
	-- 	if self:checkAddItem("SheetMetal", 25) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SheetMetal", 25) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SheetMetal", 25) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SheetMetal", 25) then totalXp = totalXp + 2 end; -- additional yield on account of fixing propane torches not draining
	-- 	if self:checkAddItem("SmallSheetMetal", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SmallSheetMetal", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SmallSheetMetal", 15) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("SmallSheetMetal", 15) then totalXp = totalXp + 2 end; -- additional yield on account of fixing propane torches not draining
	-- 	if self:checkAddItem("ScrapMetal", 12) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("ScrapMetal", 12) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("ScrapMetal", 12) then totalXp = totalXp + 2 end;
	-- 	if self:checkAddItem("ScrapMetal", 12) then totalXp = totalXp + 2 end; -- additional yield on account of fixing propane torches not draining
	-- end
	-- for i=1,10 do
	-- 	self.item:Use();
	-- end
	-- self.character:getXp():AddXP(Perks.MetalWelding, totalXp);
	-- sendClientCommand(self.character, "vehicle", "remove", { vehicle = self.vehicle:getId() })
	-- self.item:setJobDelta(0);
	
    -- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end
	
	-- ISBaseTimedAction.perform(self)
end

local old_ISRemoveBurntVehicle_forceStop = ISRemoveBurntVehicle.forceStop
function ISRemoveBurntVehicle:forceStop()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
    old_ISRemoveBurntVehicle_forceStop(self);
end

function ISRemoveBurntVehicle:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

