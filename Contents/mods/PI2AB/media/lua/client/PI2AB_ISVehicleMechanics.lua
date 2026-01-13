local transferEnginePartsOnComplete = function(completedAction)
    if completedAction.pi2ab_timestamp then
        PI2AB.LastMechanicTimestamp = completedAction.pi2ab_timestamp
    end
end

local old_ISVehicleMechanics_onTakeEngineParts = ISVehicleMechanics.onTakeEngineParts
function ISVehicleMechanics.onTakeEngineParts(playerObj, part)
    old_ISVehicleMechanics_onTakeEngineParts(playerObj, part)
    
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(playerObj) then
        return
    end

    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    if queue then
        local action = PI2ABUtil.GetTakeEnginePartsAction(queue)
        if action then
            local beforeItems = playerObj:getInventory():getItems()
            action:setOnComplete(transferEnginePartsOnComplete, action)

            local timestamp = os.time()
            action.pi2ab_timestamp = timestamp
            PI2ABComparer.create(timestamp, beforeItems)
        end
    end
end