require "TimedActions/ISBaseTimedAction"

PI2ABDummyAction = ISBaseTimedAction:derive("PI2ABDummyAction")

function PI2ABDummyAction:isValid()
    return true
end

-- function PI2ABDummyAction:update()    
--     if isClient() then
--         local duration = self.maxTime
--         if duration > 0 then
--             self.maxTime = duration
--             self.action:setTime(self.maxTime)
--         end
--     end
-- end

-- function PI2ABDummyAction:start()
-- 	if isClient() then
-- 		self.action:setWaitForFinished(true)
-- 	end
-- 	self.started = true
-- end

-- function PI2ABDummyAction:forceComplete()
-- 	if not isClient() then
-- 		return
-- 	end
-- 	self.maxTime = 0.0
-- 	self.action:setTime(self.maxTime)
-- 	self.item:setJobDelta(0.0)
-- 	self.action:forceComplete()
-- end

-- function PI2ABDummyAction:stop()
-- 	ISBaseTimedAction.stop(self)
-- 	self.started = false
-- end

-- function PI2ABDummyAction:perform()
--     if isClient() then
--         self.action:setWaitForFinished(false)
--     end

--     -- needed to remove from queue / start next.
--     ISBaseTimedAction.perform(self)
--     self.started = false
-- end

-- function PI2ABDummyAction:setMaxTime(newTime)
--     self.maxTime = newTime
-- end

-- function PI2ABDummyAction:getDuration()
-- 	if self.character:isTimedActionInstant() then
-- 		return 2;
-- 	end
-- 	if not self.craftRecipe then
-- 		return -1;
-- 	end
-- 	return (self.craftRecipe:getTime(self.character) * 5) + 1;
-- end

function PI2ABDummyAction:new(character,craftRecipe,pi2ab_timestamp)
    local o = ISBaseTimedAction.new(self, character)
	o.stopOnAim = false

	o.maxTime = 1
    o.pi2ab_timestamp = pi2ab_timestamp
    o.craftRecipe = craftRecipe
    return o
end