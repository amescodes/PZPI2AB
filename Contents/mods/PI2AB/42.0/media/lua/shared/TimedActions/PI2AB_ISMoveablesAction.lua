local old_ISMoveablesAction_complete = ISMoveablesAction.complete
function ISMoveablesAction:complete()
    old_ISMoveablesAction_complete(self)
	
	if isServer() then
		PI2ABUtil.Delay(function()
			local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(self.moveProps.material)
			local player = self.character
			local uniqueId = PI2ABUtil.GetMoveableUniqueId(self.object)
			if scrapDef and scrapDef.addToInventory then
				sendServerCommand(player, 'PI2AB', 'transferFromInventoryOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = uniqueId})
			else
				sendServerCommand(player, 'PI2AB', 'transferFromGroundOnCraftComplete', { playerNum = player:getPlayerNum(), timestamp = uniqueId, x = self.square:getX(), y = self.square:getY(), z = self.square:getZ()})
			end
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

local old_ISMoveablesAction_forceStop = ISMoveablesAction.forceStop
function ISMoveablesAction:forceStop()
	local uniqueId = PI2ABUtil.GetMoveableUniqueId(self.object) or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end
	
    old_ISMoveablesAction_forceStop(self);
end

local old_ISMoveablesAction_forceCancel = ISMoveablesAction.forceCancel
function ISMoveablesAction:forceCancel()
	local uniqueId = PI2ABUtil.GetMoveableUniqueId(self.object) or nil
	if not isServer() and uniqueId then PI2ABComparer.remove(uniqueId) end

	old_ISMoveablesAction_forceCancel(self)
end

function ISMoveablesAction:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end