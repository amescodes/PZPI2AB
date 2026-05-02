local function transferEnginePartsOnComplete(player, square,timestamp)
    if isServer() then
        return
    end

    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end
    
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBagFromInventory(player, targetContainer, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end

    PI2ABComparer.remove(timestamp)
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
        local action,i = PI2ABUtil.GetTakeEnginePartsAction(queue)
        if action then
            local timestamp = action.vehicle:getId()
            action:setOnComplete(transferEnginePartsOnComplete, playerObj, part:getVehicle(), timestamp)

            local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
            PI2ABComparer.create(timestamp, actionsToAddBack, playerObj:getInventory():getItems())

            local dummyAction = PI2ABDummyAction:new(playerObj, timestamp)
            ISTimedActionQueue.addAfter(action, dummyAction)
        end
    end
end