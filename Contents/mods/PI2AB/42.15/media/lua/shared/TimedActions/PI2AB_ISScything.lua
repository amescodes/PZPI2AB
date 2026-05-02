local old_ISScything_complete = ISScything.complete
function ISScything:complete()
    old_ISScything_complete(self)

	if isServer() then
		local player = self.character
		local sq = self.sq
        local uniqueId = PI2ABUtil.GetSqUniqueId("scythe",sq)
		PI2ABUtil.Delay(function()
			sendServerCommand(player, 'PI2AB', 'transferFromInventoryOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = uniqueId})
		end, 1)
		return true
	end

    -- SINGLE PLAYER
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end

    return true
end

local old_ISScything_forceStop = ISScything.forceStop
function ISScything:forceStop()
	local uniqueId = PI2ABUtil.GetSqUniqueId("scythe",self.sq) or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end
	
    old_ISScything_forceStop(self);
end

local old_ISScything_forceCancel = ISScything.forceCancel
function ISScything:forceCancel()
	local uniqueId = PI2ABUtil.GetSqUniqueId("scythe",self.sq) or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end

	old_ISScything_forceCancel(self)
end

function ISScything:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

