local old_ISHandcraftAction_forceStop = ISHandcraftAction.forceStop
function ISHandcraftAction:forceStop()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
    old_ISHandcraftAction_forceStop(self);
end

local old_ISHandcraftAction_forceCancel = ISHandcraftAction.forceCancel
function ISHandcraftAction:forceCancel()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
	old_ISHandcraftAction_forceCancel(self)
end
