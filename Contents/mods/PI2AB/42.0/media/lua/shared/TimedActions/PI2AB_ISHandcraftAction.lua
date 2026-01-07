local old_ISHandcraftAction_forceStop = ISHandcraftAction.forceStop
function ISHandcraftAction:forceStop()	
	local timestamp = self.onCompleteArgs and self.onCompleteArgs[3] or nil
	if not isServer() and timestamp then PI2ABComparer.remove(timestamp) end
	
    old_ISHandcraftAction_forceStop(self);
end

local old_ISHandcraftAction_forceCancel = ISHandcraftAction.forceCancel
function ISHandcraftAction:forceCancel()
	local timestamp = self.onCompleteArgs and self.onCompleteArgs[3] or nil
	if not isServer() and timestamp then PI2ABComparer.remove(timestamp) end

	old_ISHandcraftAction_forceCancel(self)
end