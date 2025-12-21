-- require "ISDestroyCursor"

-- local transferOnCraftComplete = function(completedAction, playerObj, square)
--     if completedAction.pi2ab_timestamp then
--         PI2AB.LastBuildDismantleTimestamp = completedAction.pi2ab_timestamp
--     end
-- end

-- local old_ISDestroyCursor_create = ISDestroyCursor.create
-- function ISDestroyCursor:create(x, y, z, north, sprite)
--     old_ISDestroyCursor_create(self, x, y, z, north, sprite)
--     local playerObj = self.character
    
--     if not PI2AB.IsAllowed(playerObj) then
--         return
--     end
-- 	local square = getCell():getGridSquare(x, y, z)

--     if playerObj and self.dismantle then
--         local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
--         if queue then
--             local action = PI2ABUtil.GetDismantleAction(queue)
--             if action then
--                 action:setOnComplete(transferOnCraftComplete, action, playerObj,square)

--                 local timestamp = os.time()
--                 action.pi2ab_timestamp = timestamp
--                 PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
--             end
--         end
--     end
-- end