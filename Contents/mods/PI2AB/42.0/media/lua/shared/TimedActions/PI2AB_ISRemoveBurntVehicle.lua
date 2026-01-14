
local old_ISRemoveBurntVehicle_complete = ISRemoveBurntVehicle.complete
function ISRemoveBurntVehicle:complete()
    old_ISRemoveBurntVehicle_complete(self)

	if isServer() then
		local player = self.character
		local vehicle = self.vehicle
		local uniqueId = vehicle:getId()
		local square = vehicle:getSquare()
		PI2ABUtil.Delay(function()
			sendServerCommand(player, 'PI2AB', 'transferFromGroundOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = uniqueId, x = square:getX(), y = square:getY(), z = square:getZ()})
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

local old_ISRemoveBurntVehicle_forceStop = ISRemoveBurntVehicle.forceStop
function ISRemoveBurntVehicle:forceStop()
	local timestamp = self.onCompleteArgs and self.onCompleteArgs[3] or nil
	if not isServer() and timestamp then PI2ABComparer.remove(timestamp) end

    old_ISRemoveBurntVehicle_forceStop(self);
end

local old_ISRemoveBurntVehicle_forceCancel = ISRemoveBurntVehicle.forceCancel
function ISRemoveBurntVehicle:forceCancel()
	local timestamp = self.onCompleteArgs and self.onCompleteArgs[3] or nil
	if not isServer() and timestamp then PI2ABComparer.remove(timestamp) end

	old_ISRemoveBurntVehicle_forceCancel(self)
end

function ISRemoveBurntVehicle:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end
