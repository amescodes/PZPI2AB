ISInventoryPaneContextMenu_transferOnCraftComplete = function(completedAction, recipe, playerObj, selectedItemContainer,container,containers,selectedItem,all)
    local targetContainer = ChooseDisassemblyInventory:getTargetContainer(playerObj)
    local destinationContainer
    if targetContainer then
        destinationContainer = targetContainer
    end
    if not destinationContainer then
        destinationContainer = selectedItemContainer
    end

    local previousAction = completedAction
    local src = recipe:getSource()
    if src then
        local playerInv = playerObj:getInventory()
        local allItems = playerInv:getItems()

        ChooseDisassemblyInventoryPrint("---------AFTER INVENTORY-----------")
        ChooseDisassemblyInventory_PrintArray(allItems)
        ChooseDisassemblyInventoryPrint("---------------END-----------------")
        
        if completedAction.timestamp then
            local comparer = ChooseDisassemblyInventoryComparer.get(completedAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems,src)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local finalDestContainer
                        if destinationContainer:hasRoomFor(playerObj, it) then
                            finalDestContainer = destinationContainer
                        else
                            finalDestContainer = playerInv
                        end

                        local action = ISInventoryTransferAction:new(playerObj, it, playerInv,
                        finalDestContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            ISTimedActionQueue.addAfter(completedAction, action)
                        end
                        previousAction = action
                    end
                end
            end
        end
    end

    if all then
        -- from ISInventoryPaneContextMenu.OnCraft
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
            return;
        end

        local returnToContainer = {}
        if not recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerObj:getInventory() then
                    local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), playerObj:getInventory(), nil)
                    if not action.ignoreAction then
                        ISTimedActionQueue.addAfter(previousAction, action)
                        previousAction = action
                    end
                    table.insert(returnToContainer, item)
                end
            end
        end

        local additionalTime = 0
        if container == playerObj:getInventory() and recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerObj:getInventory() then
                    local w = item:getActualWeight()
                    if w > 3 then w = 3; end;
                    additionalTime = additionalTime + 50*w
                end
            end
        end

        local action = ISCraftAction:new(playerObj, items:get(0), recipe:getTimeToMake() + additionalTime, recipe, container, containers)
        action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,selectedItem,all)
        
        local timestamp = os.time()
        action.timestamp = timestamp
        ChooseDisassemblyInventoryComparer.create(timestamp,playerObj:getInventory():getItems())

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    end
end

local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
    old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)
    if ChooseDisassemblyInventory.Enabled then
        local src = recipe:getSource()
        if src then
            local playerObj = getSpecificPlayer(player)
            local playerInv = playerObj:getInventory()
            local container = selectedItem:getContainer()
            local containers = ISInventoryPaneContextMenu.getContainers(playerObj)
            local selectedItemContainer = selectedItem:getContainer()

            ChooseDisassemblyInventoryPrint("---------BEFORE INVENTORY-----------")
            ChooseDisassemblyInventory_PrintArray(playerInv:getItems())
            ChooseDisassemblyInventoryPrint("---------------END------------------")

            local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
            local count = #queue;
            if queue and count then
                local action = queue[count]
                action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,selectedItem,all)
                
                local timestamp = os.time()
                action.timestamp = timestamp
                ChooseDisassemblyInventoryComparer.create(timestamp,playerInv:getItems())
            end
        end
    end
end
