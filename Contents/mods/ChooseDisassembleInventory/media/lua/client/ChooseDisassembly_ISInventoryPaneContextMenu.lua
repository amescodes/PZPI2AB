local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
	old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)

    -- local res = recipe:getResult()
    -- if res then
    --     local playerObj = getSpecificPlayer(player)
    --     local resItemType = res:getType()
    --     local count = res:getCount()
    --     local playerInv = playerObj:getInventory()
    --     if playerInv:containsType(resItemType) then
    --         for _=1,count do
    --             local it = playerInv:FindAndReturn(resItemType)
    --             if it then
    --                 local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(), selectedItem:getContainer(), nil)
    --                 action:setAllowMissingItems(true)
    --                 ISTimedActionQueue.add(action)
    --             end
    --         end
    --     end
    -- end
end

local old_ISInventoryPaneContextMenu_OnCraftComplete = ISInventoryPaneContextMenu.OnCraftComplete
ISInventoryPaneContextMenu.OnCraftComplete = function(completedAction, recipe, playerObj, container, containers, selectedItemType, selectedItemContainer)
	old_ISInventoryPaneContextMenu_OnCraftComplete(completedAction, recipe, playerObj, container, containers, selectedItemType, selectedItemContainer)
    ChooseDisassemblyInventory_PrintQueue(playerObj)
    local res = recipe:getResult()
    if res then
        local resItemType = res:getFullType()
        local count = res:getCount()
        local playerInv = playerObj:getInventory()
        if playerInv:containsType(resItemType) then
            local previousAction = completedAction
            for _=1,count do
                local it = playerInv:FindAndReturn(resItemType)
                if it then
                    local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(), selectedItemContainer, nil)
                    if not action.ignoreAction then
                        ISTimedActionQueue.addAfter(previousAction, action)
                        previousAction = action
                    end
                end
            end
        end
    end
end