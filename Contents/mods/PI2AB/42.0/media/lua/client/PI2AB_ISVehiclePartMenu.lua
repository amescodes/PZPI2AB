local transferOnCraftComplete = function(completedAction, playerObj, square)
    PI2ABUtil.PutInBagFromInventory(playerObj, completedAction)
    -- local playerInv = playerObj:getInventory()
    -- local targetContainer = PI2AB.getTargetContainer(playerObj)
    -- local playerNum = playerObj:getPlayerNum()

    -- if pdata == nil then pdata = getPlayerData(playerNum) end
    -- if pdata then pdata.playerInventory:refreshBackpacks() end

    -- if completedAction.timestamp then
    --     local comparer = PI2ABComparer.get(completedAction.timestamp)
    --     if comparer then
    --         local allItems = playerInv:getItems()
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
    --                     destinationContainer = nil
    --                 else
    --                     destinationContainer = ISInventoryPage.GetFloorContainer(playerNum)
    --                 end
    --             end
                
    --             if destinationContainer then
    --                 local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
    --                 tAction:setAllowMissingItems(true)
    --                 if not tAction.ignoreAction then
    --                     ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
    --                 end
    --             end
    --         end
            
    --         PI2ABComparer.remove(completedAction.timestamp)
    --     end
    -- end
end

local old_ISVehiclePartMenu_onUninstallPart = ISVehiclePartMenu.onUninstallPart
function ISVehiclePartMenu.onUninstallPart(playerObj, part)
    old_ISVehiclePartMenu_onUninstallPart(playerObj, part)

    if not PI2ABUtil.IsAllowed(playerObj) then
        return
    end

    if playerObj and part then
        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetUninstallVehiclePartAction(queue)
            if action then
                action:setOnComplete(transferOnCraftComplete, action, playerObj,part:getVehicle():getSquare())

                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
            end
        end
    end
end
