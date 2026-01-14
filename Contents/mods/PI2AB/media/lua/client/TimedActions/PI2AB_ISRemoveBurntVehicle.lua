
local old_ISRemoveBurntVehicle_perform = ISRemoveBurntVehicle.perform
function ISRemoveBurntVehicle:perform()
    old_ISRemoveBurntVehicle_perform(self)

    -- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end
end

local old_ISRemoveBurntVehicle_forceStop = ISRemoveBurntVehicle.forceStop
function ISRemoveBurntVehicle:forceStop()
	if self.pi2ab_timestamp then 
		PI2ABComparer.remove(self.pi2ab_timestamp)
	end
	
    old_ISRemoveBurntVehicle_forceStop(self);
end

function ISRemoveBurntVehicle:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end

