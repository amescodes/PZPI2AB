local function transferVehiclePartOnComplete(player, square,timestamp)
    if isServer() then
        return
    end

    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end
    
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBagFromInventory(player, targetContainer, timestamp, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end

    PI2ABComparer.remove(timestamp)
end

local old_ISVehiclePartMenu_onUninstallPart = ISVehiclePartMenu.onUninstallPart
function ISVehiclePartMenu.onUninstallPart(player, part)
    old_ISVehiclePartMenu_onUninstallPart(player, part)
    
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(player) then
        return
    end

    if player and part then
        local queueObj = ISTimedActionQueue.getTimedActionQueue(player)
        local queue = queueObj.queue
        if queue then
            local action,i = PI2ABUtil.GetUninstallVehiclePartAction(queue)
            if action then
                local timestamp = os.time()
                action:setOnComplete(transferVehiclePartOnComplete, player, part:getVehicle():getSquare(),timestamp)

                local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
                PI2ABComparer.create(timestamp, actionsToAddBack, player:getInventory():getItems())

                local dummyAction = PI2ABDummyAction:new(player, timestamp)
                ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
    end
end
