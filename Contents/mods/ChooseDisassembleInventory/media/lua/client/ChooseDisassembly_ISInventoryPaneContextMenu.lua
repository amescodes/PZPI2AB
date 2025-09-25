require "ChooseDisassemblyInventoryComparer"

local transferOnCraftComplete = function(completedAction, recipe, playerObj, container, containers, selectedItemType,
    selectedItemContainer)
    -- ChooseDisassemblyInventory_PrintQueue(playerObj)
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
                comparer:compare(allItems,src)
            end
        end
    end
end

local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
    old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)
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
        if not all then
            -- ChooseDisassemblyInventory_PrintQueue(playerObj)
            local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
            local count = #queue;
            if queue and count then
                local action = queue[count]
                action:setOnComplete(transferOnCraftComplete, action, recipe, playerObj, container, containers,
                    selectedItem:getFullType(), selectedItemContainer)

                local timestamp = os.time()
                action.timestamp = timestamp
                ChooseDisassemblyInventoryComparer.create(timestamp,playerObj:getInventory():getItems())
            end
        end
    end
end

local old_ISInventoryPaneContextMenu_OnCraftComplete = ISInventoryPaneContextMenu.OnCraftComplete
ISInventoryPaneContextMenu.OnCraftComplete = function(completedAction, recipe, playerObj, container, containers,
    selectedItemType, selectedItemContainer)
    old_ISInventoryPaneContextMenu_OnCraftComplete(completedAction, recipe, playerObj, container, containers,
        selectedItemType, selectedItemContainer)
    ChooseDisassemblyInventory_PrintQueue(playerObj)
    local src = recipe:getSource()
    if src then
        local playerInv = playerObj:getInventory()
        ChooseDisassemblyInventory_PrintArray(playerInv:getItems())

        -- if it then
        --     local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(),
        --         selectedItemContainer, nil)
        --     action:setAllowMissingItems(true)
        --     if not action.ignoreAction then
        --         ISTimedActionQueue.addAfter(previousAction, action)
        --         previousAction = action
        --     end
        -- end
    end
end
