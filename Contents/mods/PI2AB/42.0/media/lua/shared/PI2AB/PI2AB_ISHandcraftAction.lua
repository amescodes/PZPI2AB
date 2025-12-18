local old_ISHandcraftAction_forceStop = ISHandcraftAction.forceStop
function ISHandcraftAction:forceStop()
	if self.timestamp then PI2ABComparer.remove(self.timestamp) end
	
    old_ISHandcraftAction_forceStop(self);
end

local old_ISHandcraftAction_forceCancel = ISHandcraftAction.forceCancel
function ISHandcraftAction:forceCancel()
	if self.timestamp then PI2ABComparer.remove(self.timestamp) end
	
	old_ISHandcraftAction_forceCancel(self)
end
