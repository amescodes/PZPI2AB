require "TimedActions/ISInventoryTransferUtil"

if not PI2ABCore then
    PI2ABCore = {}
end

PI2ABCore.DefaultContainers = {'PlayerInventory', 'ItemSource'}

PI2ABCore.WhenToTransfer = {'AfterEach', 'AtEnd'}

function PI2ABCore.PutInBag(playerObj, playerInv, selectedItemContainer, targetContainer, completedAct, allItems, srcItems)
    local comparer = PI2ABComparer.get(completedAct.pi2ab_timestamp)
    local previousAct = completedAct
    local targetWeightTransferred = 0.0
    local defWeightTransferred = 0.0
    local itemIdsToTransfer
    if comparer then
        itemIdsToTransfer = comparer:compare(allItems, srcItems)
        -- target container
        local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
        PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
        local tWeight = targetContainer and targetContainer:getContentsWeight() or 0
        targetWeightTransferred = comparer.targetWeightTransferred
        local runningBagWeight = targetContainer and PI2ABUtil.Round(tWeight + targetWeightTransferred) or 0
        PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
        -- backup / default container
        local defContainer = PI2ABCore.GetDefaultContainer(selectedItemContainer, playerInv)
        local bCapacity = defContainer and defContainer:getCapacity() or 0
        PI2ABUtil.Print("default container capacity " .. tostring(bCapacity), true)
        local bWeight = defContainer and defContainer:getContentsWeight() or 0
        defWeightTransferred = comparer.defWeightTransferred
        local bRunningBagWeight = defContainer and PI2ABUtil.Round(bWeight + defWeightTransferred) or 0
        PI2ABUtil.Print("default container contents weight START " .. tostring(bRunningBagWeight), true)
        -- check new items and queue transfer actions
        -- for i = 0, itemIdsToTransfer:size() - 1 do
        for i, it in pairs(itemIdsToTransfer) do
            local itemWeight = PI2ABUtil.Round(it:getWeight())
            PI2ABUtil.Print("itemWeight: " .. tostring(itemWeight), true)
            local destinationContainer
            local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
            if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                runningBagWeight = possibleNewWeight
                targetWeightTransferred = PI2ABUtil.Round(targetWeightTransferred + itemWeight)
                destinationContainer = targetContainer
            else
                possibleNewWeight = PI2ABUtil.Round(bRunningBagWeight + itemWeight)
                if defContainer then
                    PI2ABUtil.Print("default container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                    if defContainer:getType() ~= "floor" then
                        if defContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= bCapacity then
                            bRunningBagWeight = possibleNewWeight
                            defWeightTransferred = PI2ABUtil.Round(defWeightTransferred + itemWeight)
                        end
                    end

                    destinationContainer = defContainer
                else
                    destinationContainer = playerInv
                end
            end

            if destinationContainer then
                local tAction = ISInventoryTransferUtil.newInventoryTransferAction(playerObj, it, playerInv, destinationContainer, nil)
                tAction:setAllowMissingItems(true)
                if not tAction.ignoreAction then
                    previousAct = PI2ABCore.AddWhenToTransferAction(previousAct, tAction)
                end
            end
        end

        PI2ABComparer.remove(completedAct.pi2ab_timestamp)
    end
    return PI2ABResult:new(previousAct, completedAct, itemIdsToTransfer, targetWeightTransferred, defWeightTransferred)
end

function PI2ABCore.PutInBagFromInventory(completedAction,playerObj)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)
    local playerNum = playerObj:getPlayerNum()

    local pdata = getPlayerData(playerNum)
    if pdata then pdata.playerInventory:refreshBackpacks() end

    if completedAction.pi2ab_timestamp then
        local comparer = PI2ABComparer.get(completedAction.pi2ab_timestamp)
        if comparer then
            local allItems = playerInv:getItems()
            local itemIdsToTransfer = comparer:compare(allItems, nil)
            -- target container
            local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
            PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
            local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
            PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
            -- backup / default container
            local defContainer = PI2ABCore.GetDefaultContainer(nil, playerInv)
            -- check new items and queue transfer actions
            -- for i = 0, itemIdsToTransfer:size() - 1 do
            for i, it in pairs(itemIdsToTransfer) do
                -- local it = itemIdsToTransfer:get(i)
                local itemWeight = PI2ABUtil.Round(it:getWeight())
                local destinationContainer
                local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
                if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                    PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                    runningBagWeight = possibleNewWeight
                    destinationContainer = targetContainer
                else
                    if defContainer and defContainer ~= nil then
                        destinationContainer = nil
                    else
                        destinationContainer = ISInventoryPage.GetFloorContainer(playerNum)
                    end
                end
                
                if destinationContainer then
                    local tAction = ISInventoryTransferUtil.newInventoryTransferAction(playerObj, it, playerInv, destinationContainer, nil)
                    tAction:setAllowMissingItems(true)
                    if not tAction.ignoreAction then
                        ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
                    end
                end
            end
            
            PI2ABComparer.remove(completedAction.pi2ab_timestamp)
        end
    end
end

function PI2ABCore.PutInBagFromGround(completedAction, playerObj, square)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)
    local playerNum = playerObj:getPlayerNum()

    local pdata = getPlayerData(playerNum)
    if pdata then pdata.lootInventory:refreshBackpacks() end
    
    if completedAction.pi2ab_timestamp then
        local comparer = PI2ABComparer.get(completedAction.pi2ab_timestamp)
        if comparer then
            local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
            local itemIdsToTransfer = comparer:compare(allItems, nil)
            -- target container
            local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
            PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
            local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
            PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
            -- backup / default container
            local defContainer = PI2ABCore.GetDefaultContainer(nil, playerInv)
            -- check new items and queue transfer actions            
            for i, it in pairs(itemIdsToTransfer) do
                local itemWeight = PI2ABUtil.Round(it:getWeight())
                local destinationContainer
                local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
                if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                    PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                    runningBagWeight = possibleNewWeight
                    destinationContainer = targetContainer
                else
                    if defContainer and defContainer ~= nil then
                        destinationContainer = playerInv
                    else
                        destinationContainer = nil
                    end
                end
                
                if destinationContainer then
                    local tAction = ISInventoryTransferUtil.newInventoryTransferAction(playerObj, it, ISInventoryPage.GetFloorContainer(playerNum), destinationContainer, nil)
                    tAction:setAllowMissingItems(true)
                    if not tAction.ignoreAction then
                        ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
                    end
                end
            end

            PI2ABComparer.remove(completedAction.pi2ab_timestamp)
        end
    end
end

function PI2ABCore.GetDefaultContainer(selectedItemContainer, playerInv)
    local defaultIndex = PI2AB.DefaultDestinationContainer
    if defaultIndex then
        local defOption = PI2ABCore.DefaultContainers[defaultIndex]
        if defOption == 'ItemSource' then
            return selectedItemContainer
        end
    end

    return playerInv
end

function PI2ABCore.AddWhenToTransferAction(previousAction, action)
    local whenToTransferIndex = PI2AB.WhenToTransferItems
    if whenToTransferIndex then
        local defOption = PI2ABCore.WhenToTransfer[whenToTransferIndex]
        if defOption == 'AfterEach' then
            local result = ISTimedActionQueue.addAfter(previousAction, action)
            if result then
                return action
            else
                local queue = ISTimedActionQueue.getTimedActionQueue(action.character)
                table.insert(queue.queue, 1, action)
                queue.current = action
                action:begin()
                return action
            end
        end
    end
    
    ISTimedActionQueue.getTimedActionQueue(action.character):addToQueue(action)
    return nil
end