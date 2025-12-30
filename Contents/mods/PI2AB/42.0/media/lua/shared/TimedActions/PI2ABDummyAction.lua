require "TimedActions/ISBaseTimedAction"

PI2ABDummyAction = ISBaseTimedAction:derive("PI2ABDummyAction")

function PI2ABDummyAction:isValid()
    return true
end

function PI2ABDummyAction:new(character,pi2ab_timestamp)
    local o = ISBaseTimedAction.new(self, character)
	-- o.stopOnAim = false
	o.maxTime = 5
    o.dummy = true
    o.pi2ab_timestamp = pi2ab_timestamp
    return o
end