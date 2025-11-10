require "PI2ABComparer"

ISInventoryPaneContextMenu_transferOnCraftComplete = function(completedAction, recipe, playerObj, container,containers,selectedItem,all)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB:getTargetContainer(playerObj)

    -- PI2ABUtil.Print("---------------transferOnCraftComplete-------------")
    -- PI2ABUtil.PrintQueue(playerObj)
    -- PI2ABUtil.Print("------------------------END------------------------")

    local previousAction = completedAction
    local src = recipe:getSource()
    if src then
        local allItems = playerInv:getItems()

        -- PI2ABUtil.Print("---------AFTER INVENTORY-----------")
        -- PI2ABUtil.PrintArray(allItems)
        -- PI2ABUtil.Print("---------------END-----------------")
        
        if completedAction.timestamp then
            local comparer = PI2ABComparer.get(completedAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems,src)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local destinationContainer
                        if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
                            destinationContainer = targetContainer
                        else
                            local defContainer = PI2ABUtil.GetDefaultContainer(container,playerInv)
                            if defContainer and defContainer:hasRoomFor(playerObj, it) then
                                destinationContainer = defContainer
                            else
                                destinationContainer = playerInv
                            end
                        end

                        local action = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, action)
                        end
                    end
                end
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

        local action = ISCraftAction:new(playerObj, items:get(0), recipe, container, containers)
        action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,selectedItem,all)
        
        local timestamp = os.time()
        action.timestamp = timestamp
        PI2ABComparer.create(timestamp,playerObj:getInventory():getItems())
        
        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)

        action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer,container,containers,selectedItem,all)
    end
end

local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
    old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)
    if PI2AB.Enabled then
        local playerObj = getSpecificPlayer(player)
        local playerInv = playerObj:getInventory()
        local container = selectedItem:getContainer()
        local containers = ISInventoryPaneContextMenu.getContainers(playerObj)

        -- PI2ABUtil.Print("---------BEFORE INVENTORY-----------")
        -- PI2ABUtil.PrintArray(playerInv:getItems())
        -- PI2ABUtil.Print("---------------END------------------")
        
        -- PI2ABUtil.Print("---------------ON CRAFT-------------")
        -- PI2ABUtil.PrintQueue(playerObj)
        -- PI2ABUtil.Print("---------------END------------------")

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe,queue)
            if action then
                action:setOnComplete(ISInventoryPaneContextMenu_transferOnCraftComplete, action, recipe, playerObj, container,containers,selectedItem,all)        
                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp,playerInv:getItems())
            end
        end
    end
end


local old_ISInventoryPaneContextMenu_OnNewCraftComplete = ISInventoryPaneContextMenu.OnNewCraftComplete
local ISInventoryPaneContextMenu_transferOnNewCraftComplete = function(args)
    old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)

    local playerObj = args.playerObj
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB:getTargetContainer(playerObj)

    -- PI2ABUtil.Print("---------------transferOnNewCraftComplete-------------")
    -- PI2ABUtil.PrintQueue(playerObj)
    -- PI2ABUtil.Print("------------------------END------------------------")

    local previousAction = args.completedAction
    local inputItems = args.recipe:getAllInputItems()
    if inputItems then
        local allItems = playerInv:getItems()
        if previousAction.timestamp then
            local comparer = PI2ABComparer.get(previousAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems,inputItems)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local destinationContainer
                        if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
                            destinationContainer = targetContainer
                        else
                            local defContainer = PI2ABUtil.GetDefaultContainer(args.container,playerInv)
                            if defContainer and defContainer:hasRoomFor(playerObj, it) then
                                destinationContainer = defContainer
                            else
                                destinationContainer = playerInv
                            end
                        end

                        local action = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            previousAction = PI2ABUtil.AddWhenToTransferActionHandcraft(ISTimedActionQueue.getTimedActionQueue(playerObj), action)
                        end
                    end
                end
            end
        end
    end
end

local old_ISInventoryPaneContextMenu_OnNewCraft = ISInventoryPaneContextMenu.OnNewCraft
ISInventoryPaneContextMenu.OnNewCraft = function(selectedItem, recipe, player, all, eatPercentage)
    old_ISInventoryPaneContextMenu_OnNewCraft(selectedItem, recipe, player, all, eatPercentage)

    if PI2AB.Enabled then
        local playerObj = getSpecificPlayer(player)
        local playerInv = playerObj:getInventory()
        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe, queue)
            if action then
                local logic = action.onCompleteTarget                
                local args = PI2ABTransferArgs:new(logic,nil, action, logic:getRecipeData(), playerObj, selectedItem:getContainer(), action.containers, selectedItem,all)
                action:setOnComplete(ISInventoryPaneContextMenu_transferOnNewCraftComplete, args)
                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp, playerInv:getItems())
            end
        end
    end
end

-- likely upcoming in future versions of the game
--ISInventoryPaneContextMenu.OnNewCraftCompleteAll = function(completedAction, recipe, playerObj, containers, usedItems)
--end
