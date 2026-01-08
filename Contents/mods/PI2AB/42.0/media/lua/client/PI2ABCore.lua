require "TimedActions/ISInventoryTransferUtil"

if not PI2ABCore then
    PI2ABCore = {}
end

PI2ABCore.DefaultContainers = {'PlayerInventory', 'ItemSource'}

PI2ABCore.WhenToTransfer = {'AfterEach', 'AtEnd'}

function PI2ABCore.PutInBag(playerObj, timestamp, selectedItemContainer, targetContainer, itemIdsToTransfer, tWeightTransferred, dWeightTransferred)
    if itemIdsToTransfer then
        local playerInv = playerObj:getInventory()       
        -- target container
        local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
        PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
        local tWeight = targetContainer and targetContainer:getContentsWeight() or 0
        local targetWeightTransferred = tWeightTransferred or 0.0
        local runningBagWeight = targetContainer and PI2ABUtil.Round(tWeight + targetWeightTransferred) or 0
        PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
        
        -- backup / default container
        local defContainer = PI2ABCore.GetDefaultContainer(selectedItemContainer, playerInv)
        local bCapacity = defContainer and defContainer:getCapacity() or 0
        PI2ABUtil.Print("default container capacity " .. tostring(bCapacity), true)
        local bWeight = defContainer and defContainer:getContentsWeight() or 0
        local defWeightTransferred = dWeightTransferred or 0.0
        local bRunningBagWeight = defContainer and PI2ABUtil.Round(bWeight + defWeightTransferred) or 0
        PI2ABUtil.Print("default container contents weight START " .. tostring(bRunningBagWeight), true)
        
        -- check new items and queue transfer actions
        local previousAct = PI2ABUtil.GetDummyAction(ISTimedActionQueue.getTimedActionQueue(playerObj).queue,timestamp)
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
    end
end

function PI2ABCore.PutInBagFromInventory(playerObj, targetContainer, itemIdsToTransfer)
    local playerNum = playerObj:getPlayerNum()
    
    local pdata = getPlayerData(playerNum)
    if pdata then pdata.playerInventory:refreshBackpacks() end
    
    -- target container
    local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
    PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
    local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
    PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
    -- backup / default container
    local playerInv = playerObj:getInventory()
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
                destinationContainer = nil
            else
                destinationContainer = ISInventoryPage.GetFloorContainer(playerNum)
            end
        end
        
        if destinationContainer then
            local tAction = ISInventoryTransferUtil.newInventoryTransferAction(playerObj, it, playerInv, destinationContainer, nil)
            tAction:setAllowMissingItems(true)
            if not tAction.ignoreAction then
                ISTimedActionQueue.add(tAction)
            end
        end
    end
end

function PI2ABCore.PutInBagFromGround( playerObj, targetContainer, itemIdsToTransfer)
    local playerInv = playerObj:getInventory()
    local playerNum = playerObj:getPlayerNum()

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
                ISTimedActionQueue.add(tAction)
            end
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
    local player = action.character
    local whenToTransferIndex = PI2AB.WhenToTransferItems
    if whenToTransferIndex then
        local defOption = PI2ABCore.WhenToTransfer[whenToTransferIndex]
        if defOption == 'AfterEach' then
            local result = ISTimedActionQueue.addAfter(previousAction, action)
            if result then
                return action
            else
                local queue = ISTimedActionQueue.getTimedActionQueue(player)
                table.insert(queue.queue, 1, action)
                queue.current = action
                action:begin()
                return action
            end
        end
    end
    
    ISTimedActionQueue.add(action)
    return nil
end


function PI2ABCore.GetTargetContainer(playerObj)
    local playerInv = playerObj:getInventory()
    local targetContainerId = PI2AB.TargetContainer
    if targetContainerId and targetContainerId ~= "" then
        local item = playerInv:getItemWithID(targetContainerId)
        if item and item:isEquipped() then
            return item:getItemContainer()
        end
    end
    return nil
end
