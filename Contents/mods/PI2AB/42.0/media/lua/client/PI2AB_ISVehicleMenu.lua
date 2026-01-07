local function transferVehicleItemsOnComplete(player, square,timestamp)
    if isServer() then
        return
    end

    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end

    local playerNum = player:getPlayerNum()
    local pdata = getPlayerData(playerNum)
    if pdata then pdata.lootInventory:refreshBackpacks() end
    
    local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBagFromGround(player, targetContainer, timestamp, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end

    PI2ABComparer.remove(timestamp)
end

local old_ISVehicleMenu_onRemoveBurntVehicle = ISVehicleMenu.onRemoveBurntVehicle
function ISVehicleMenu.onRemoveBurntVehicle(player, vehicle)
    old_ISVehicleMenu_onRemoveBurntVehicle(player, vehicle)

    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(player) then
        return
    end

    if player and vehicle then
        local square = vehicle:getSquare()
        local queueObj = ISTimedActionQueue.getTimedActionQueue(player)
        local queue = queueObj.queue
        if queue then
            local action,i = PI2ABUtil.GetRemoveBurntVehicleAction(queue)
            if action then
                local timestamp = os.time()
                local beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
                action:setOnComplete(transferVehicleItemsOnComplete, player, square,timestamp)

                local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
                PI2ABComparer.create(timestamp, actionsToAddBack, beforeItems)

                local dummyAction = PI2ABDummyAction:new(player, timestamp)
                ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
    end
end