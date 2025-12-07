ISInventoryPaneContextMenu_transferOnCraftComplete = function(completedAction, recipe, playerObj, selectedItemContainer,container,containers,all)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local previousAction = completedAction
    local src = recipe:getSource()
    local itemsToTransfer
    if src then
        local srcItems = PI2ABUtil.GetActualItemsFromSource(playerInv,src)
        local allItems = playerInv:getItems()
        if completedAction.timestamp then
            local comparer = PI2ABComparer.get(completedAction.timestamp)
            if comparer then
                itemsToTransfer = comparer:compare(allItems,srcItems)
                -- target container
                local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
                PI2ABUtil.Print("target container capacity "..tostring(capacity), true)
                local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
                PI2ABUtil.Print("target container contents weight START "..tostring(runningBagWeight), true)
                -- backup / default container
                local defContainer = PI2ABUtil.GetDefaultContainer(selectedItemContainer,playerInv)
                local bCapacity = defContainer and defContainer:getCapacity() or 0
                PI2ABUtil.Print("default container capacity "..tostring(bCapacity), true)
                local bRunningBagWeight = defContainer and defContainer:getContentsWeight() or 0
                PI2ABUtil.Print("default container contents weight START "..tostring(bRunningBagWeight), true)
                -- check new items and queue transfer actions
                for i = 0, itemsToTransfer:size() - 1 do
                    local it = itemsToTransfer:get(i)
                    local itemWeight = it:getWeight()
                    local destinationContainer
                    local possibleNewWeight = PZMath.roundFromEdges(runningBagWeight + itemWeight)
                    if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                        PI2ABUtil.Print("target container possibleNewWeight: "..tostring(possibleNewWeight), true)
                        runningBagWeight = possibleNewWeight
                        destinationContainer = targetContainer
                    else
                        possibleNewWeight = PZMath.roundFromEdges(bRunningBagWeight + itemWeight)
                        local type = defContainer:getType()
                        if defContainer and type == "floor" or (defContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= bCapacity) then
                            PI2ABUtil.Print("default container possibleNewWeight: "..tostring(possibleNewWeight), true)
                            bRunningBagWeight = possibleNewWeight
                            destinationContainer = defContainer
                        else
                            destinationContainer = playerInv
                        end
                    end

                    local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                    tAction:setAllowMissingItems(true)
                    if not tAction.ignoreAction then
                        previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, tAction)
                    end
                end

                PI2ABComparer.remove(completedAction.timestamp)
            end
        end
    end

    if all then
        -- from ISInventoryPaneContextMenu.OnCraftComplete
        if not RecipeManager.IsRecipeValid(recipe, playerObj, nil, containers) then return end
        local items = nil
        if recipe:isInSameInventory() then
            local tItems = selectedItemContainer:getItems()
            local tSelectedItem = nil
            for i=0, tItems:size()-1 do
                local v = recipe:getSource():get(0):getItems()
                for j=0, v:size()-1 do
                    if tItems:get(i):getFullType() == v:get(j) then
                        tSelectedItem = tItems:get(i)
                        break
                    end
                end
                if tSelectedItem ~= nil then
                    break
                end
            end

            if tSelectedItem ~= nil then
                items = RecipeManager.getAvailableItemsNeeded(recipe, playerObj, containers, tSelectedItem, nil)
            end
        else
            items = RecipeManager.getAvailableItemsNeeded(recipe, playerObj, containers, nil, nil)
        end

        if items == nil or items:isEmpty() then return end
        if not ISInventoryPaneContextMenu.canAddManyItems(recipe, items:get(0), playerObj) then
            return
        end

        if previousAction == nil then
            previousAction = completedAction
        end

        local returnToContainer = {}
        if not recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerInv then
                    local zAction = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), playerInv, nil)
                    zAction:setAllowMissingItems(true)
                    if not zAction.ignoreAction then
                        ISTimedActionQueue.addAfter(previousAction, zAction)
                        previousAction = zAction
                    end
                    table.insert(returnToContainer, item)
                end
            end
        end

        local additionalTime = 0
        if container == playerInv and recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerInv then
                    local w = item:getActualWeight()
                    if w > 3 then w = 3 end
                    additionalTime = additionalTime + 50*w
                end
            end
        end

        local action = ISCraftAction:new(playerObj, items:get(0), recipe:getTimeToMake() + additionalTime, recipe, container, containers)
        action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,all)

        local timestamp = os.time()
        action.timestamp = timestamp
        PI2ABComparer.create(timestamp,playerInv:getItems(),itemsToTransfer)

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    end
end

local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
    old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)
    if PI2AB.Enabled then

        local playerObj = getSpecificPlayer(player)
        local playerInv = playerObj:getInventory()
        local container = selectedItem:getContainer()
        local selectedItemContainer = container
        if not recipe:isCanBeDoneFromFloor() then
            container = playerObj:getInventory()
        end
        local containers = ISInventoryPaneContextMenu.getContainers(playerObj)

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe,queue)
            if action then
                action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,all)
                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp,playerInv:getItems())
            end
        end
    end
end
