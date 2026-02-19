
local old_ISUninstallVehiclePart_complete = ISUninstallVehiclePart.complete
function ISUninstallVehiclePart:complete()
    old_ISUninstallVehiclePart_complete(self)

	if isServer() then
		local player = self.character
		local id = self.part:getId()
		PI2ABUtil.Delay(function()
			sendServerCommand(player, 'PI2AB', 'transferFromInventoryOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = id})
		end, 1)
		return true
	end

    -- SINGLE PLAYER
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end

    return true;
end

local old_ISUninstallVehiclePart_forceStop = ISUninstallVehiclePart.forceStop
function ISUninstallVehiclePart:forceStop()	
	local uniqueId = self.part:getId() or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end
	
    old_ISUninstallVehiclePart_forceStop(self);
end

local old_ISUninstallVehiclePart_forceCancel = ISUninstallVehiclePart.forceCancel
function ISUninstallVehiclePart:forceCancel()	
	local uniqueId = self.part:getId() or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end
	
	old_ISUninstallVehiclePart_forceCancel(self)
end

function ISUninstallVehiclePart:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

