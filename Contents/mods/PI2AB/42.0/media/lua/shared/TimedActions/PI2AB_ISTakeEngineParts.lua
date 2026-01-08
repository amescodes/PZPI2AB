local old_ISTakeEngineParts_complete = ISTakeEngineParts.complete
function ISTakeEngineParts:complete()
    old_ISTakeEngineParts_complete(self)

	if isServer() then
		PI2ABUtil.Delay(function()
			local player = self.character
			sendServerCommand(player, 'PI2AB', 'transferFromInventoryOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = self.part:getId()})
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

local old_ISTakeEngineParts_forceStop = ISTakeEngineParts.forceStop
function ISTakeEngineParts:forceStop()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
    old_ISTakeEngineParts_forceStop(self);
end

local old_ISTakeEngineParts_forceCancel = ISTakeEngineParts.forceCancel
function ISTakeEngineParts:forceCancel()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
	old_ISTakeEngineParts_forceCancel(self)
end

function ISTakeEngineParts:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

