local old_ISUninstallVehiclePart_perform = ISUninstallVehiclePart.perform
function ISUninstallVehiclePart:perform()
    old_ISUninstallVehiclePart_perform(self)

	-- local perksTable = VehicleUtils.getPerksTableForChr(self.part:getTable("install").skills, self.character)
	-- local args = { vehicle = self.vehicle:getId(), part = self.part:getId(),
	-- 				perks = perksTable,
	-- 				mechanicSkill = self.character:getPerkLevel(Perks.Mechanics),
	-- 				contentAmount = self.part:getContainerContentAmount() }
	-- sendClientCommand(self.character, 'vehicle', 'uninstallPart', args)

    -- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end

	-- ISBaseTimedAction.perform(self)
end

local old_ISUninstallVehiclePart_forceStop = ISUninstallVehiclePart.forceStop
function ISUninstallVehiclePart:forceStop()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
    old_ISUninstallVehiclePart_forceStop(self);
end

function ISUninstallVehiclePart:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

