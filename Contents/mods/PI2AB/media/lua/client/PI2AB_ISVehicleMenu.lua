-- local pdata = nil
local transferFromGroundOnCraftComplete = function(completedAction, playerObj, square)
    -- PI2ABUtil.PutInBagFromGround(playerObj, completedAction, square)
    if completedAction.pi2ab_timestamp then
        playerObj.pi2ab_mechanicTimestamp = completedAction.pi2ab_timestamp
    end
    -- local playerInv = playerObj:getInventory()
    -- local targetContainer = PI2AB.getTargetContainer(playerObj)
    -- local playerNum = playerObj:getPlayerNum()

    -- if pdata == nil then pdata = getPlayerData(playerNum) end
    -- if pdata then pdata.lootInventory:refreshBackpacks() end

    -- if completedAction.pi2ab_timestamp then
    --     local comparer = PI2ABComparer.get(completedAction.pi2ab_timestamp)
    --     if comparer then
    --         local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
    --         local itemsToTransfer = comparer:compare(allItems, nil)
    --         -- target container
    --         local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
    --         PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
    --         local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
    --         PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
    --         -- backup / default container
    --         local defContainer = PI2ABUtil.GetDefaultContainer(nil, playerInv)
    --         -- check new items and queue transfer actions            
    --         for i = 0, itemsToTransfer:size() - 1 do
    --             local it = itemsToTransfer:get(i)
    --             local itemWeight = it:getWeight()
    --             local destinationContainer
    --             local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
    --             if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
    --                 PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
    --                 runningBagWeight = possibleNewWeight
    --                 destinationContainer = targetContainer
    --             else
    --                 if defContainer and defContainer ~= nil then
    --                     destinationContainer = playerInv
    --                 else
    --                     destinationContainer = nil
    --                 end
    --             end

    --             if destinationContainer then
    --                 local tAction = ISInventoryTransferAction:new(playerObj, it, ISInventoryPage.GetFloorContainer(playerNum), destinationContainer, nil)
    --                 tAction:setAllowMissingItems(true)
    --                 if not tAction.ignoreAction then
    --                     ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
    --                 end
    --             end
    --         end

    --         PI2ABComparer.remove(completedAction.pi2ab_timestamp)
    --     end
    -- end
end

local old_ISVehicleMenu_onRemoveBurntVehicle = ISVehicleMenu.onRemoveBurntVehicle
function ISVehicleMenu.onRemoveBurntVehicle(player, vehicle)
    old_ISVehicleMenu_onRemoveBurntVehicle(player, vehicle)

    if not PI2ABUtil.IsAllowed(player) then
        return
    end

    if player and vehicle then
        local square = vehicle:getSquare()
        local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
        if queue then
            local action = PI2ABUtil.GetRemoveBurntVehicleAction(queue)
            if action then
                local beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
                action:setOnComplete(transferFromGroundOnCraftComplete, action, player, square)

                local timestamp = os.time()
                action.pi2ab_timestamp = timestamp
                PI2ABComparer.create(timestamp, beforeItems)
            end
        end
    end
end