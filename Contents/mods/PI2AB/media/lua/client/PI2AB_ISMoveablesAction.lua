-- overwrites ISMoveablesAction:perform to add onComplete callback functionality
local old_ISMoveablesAction_perform = ISMoveablesAction.perform
function ISMoveablesAction:perform()
    old_ISMoveablesAction_perform(self)

    -- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end
end

local old_ISMoveablesAction_forceStop = ISMoveablesAction.forceStop
function ISMoveablesAction:forceStop()
	if self.timestamp then PI2ABComparer.remove(self.timestamp) end
	
    old_ISMoveablesAction_forceStop(self);
end

function ISMoveablesAction:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end