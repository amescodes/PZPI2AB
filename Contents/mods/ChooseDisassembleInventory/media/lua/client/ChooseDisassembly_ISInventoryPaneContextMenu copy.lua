local function craftRecipe(playerObj, recipe, selectedItemContainer, onComplete, arg)
    local t2 = playerObj:getCharacterActions()
    local res2 = recipe:getSource()
    ChooseDisassemblyInventory_PrintArray(res2)
    local res = recipe:getResult()
    local mod = recipe:getModule()
    local ct = recipe:getModule()
    if res then
        local resItemType =  res:getFullType()
        local targetContainer = ChooseDisassemblyInventory:getTargetContainer(playerObj)
        local destinationContainer
        if targetContainer then
            destinationContainer = targetContainer
        end
        if not destinationContainer then
            destinationContainer = selectedItemContainer
        end

        local playerInv = playerObj:getInventory()
        if onComplete and playerInv:containsType(resItemType) then
            local previousAction = arg
            for _ = 1, res:getCount() do
                local it = playerInv:FindAndReturn(resItemType)
                if it and destinationContainer then
                    -- local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(), selectedItem:getContainer(), nil)
                    local action = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                    action:setAllowMissingItems(true)
                    if not action.ignoreAction then
                        ISTimedActionQueue.addAfter(previousAction, action)
                        previousAction = action
                    end
                end
            end
        else
            local checkAction = ChooseDisassemblyInventory_CheckInventory:new(playerObj, destinationContainer, recipe)
            ISTimedActionQueue.add(checkAction)
        end
    end
end

local old_ISInventoryPaneContextMenu_OnCraft = ISInventoryPaneContextMenu.OnCraft
ISInventoryPaneContextMenu.OnCraft = function(selectedItem, recipe, player, all)
    ChooseDisassemblyInventoryPrint("begin old ISInventoryPaneContextMenu.OnCraft")
    old_ISInventoryPaneContextMenu_OnCraft(selectedItem, recipe, player, all)
    if not all then
        ChooseDisassemblyInventoryPrint("begin CD ISInventoryPaneContextMenu.OnCraft")
        local playerObj = getSpecificPlayer(player)
        local c = selectedItem:getContainer()
        craftRecipe(playerObj, recipe, selectedItem:getContainer(), false, selectedItem)

        -- local res = recipe:getResult()
        -- if res then

        --     local resItemType = res:getType()
        --     local targetContainer = ChooseDisassemblyInventory:getTargetContainer(playerObj)
        --     local destinationContainer
        --     if targetContainer then
        --         destinationContainer = targetContainer
        --     end
        --     if not destinationContainer then
        --         destinationContainer = selectedItem:getContainer()
        --     end

        --     local playerInv = playerObj:getInventory()
        --     if playerInv:containsType(resItemType) then
        --         for _ = 1, res:getCount() do
        --             local it = playerInv:FindAndReturn(resItemType)
        --             if it then
        --                 -- local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(), selectedItem:getContainer(), nil)
        --                 local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(), destinationContainer, nil)
        --                 action:setAllowMissingItems(true)
        --                 ISTimedActionQueue.add(action)
        --             end
        --         end
        --     end
        -- end
    end
end

local old_ISInventoryPaneContextMenu_OnCraftComplete = ISInventoryPaneContextMenu.OnCraftComplete
ISInventoryPaneContextMenu.OnCraftComplete = function(completedAction, recipe, playerObj, container, containers,
    selectedItemType, selectedItemContainer)
    ChooseDisassemblyInventoryPrint("begin old ISInventoryPaneContextMenu.OnCraftComplete")
    old_ISInventoryPaneContextMenu_OnCraftComplete(completedAction, recipe, playerObj, container, containers,
        selectedItemType, selectedItemContainer)
    ChooseDisassemblyInventoryPrint("begin CD ISInventoryPaneContextMenu.OnCraftComplete")
    craftRecipe(playerObj, recipe, selectedItemContainer, true, completedAction)

    -- local res = recipe:getResult()
    -- if res then

    --     local resItemType = res:getFullType()
    --     local targetContainer = ChooseDisassemblyInventory:getTargetContainer(playerObj)
    --     local destinationContainer
    --     if targetContainer then
    --         destinationContainer = targetContainer
    --     end
    --     if not destinationContainer then
    --         destinationContainer = selectedItemContainer
    --     end

    --     local playerInv = playerObj:getInventory()
    --     if playerInv:containsType(resItemType) then
    --         local previousAction = completedAction
    --         for _ = 1, res:getCount() do
    --             local it = playerInv:FindAndReturn(resItemType)
    --             if it and destinationContainer then
    --                 local action = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
    --                 action:setAllowMissingItems(true)
    --                 if not action.ignoreAction then
    --                     ISTimedActionQueue.addAfter(previousAction, action)
    --                     previousAction = action
    --                 end
    --             end
    --         end
    --     end
    -- end
end

local function makeTargetContainer(item, player)
    if item then
        ChooseDisassemblyInventory:setTargetContainer(player, item)
    end
end

local function ChooseDisassemblyInventoryContextMenuEntry(player, context, items)
    if not ChooseDisassemblyInventory.Enabled then
        return
    end

    -- items = ISInventoryPane.getActualItems(items)
    for _, v in ipairs(items) do
        local testItem = v
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
        -- todo check not keys!
        if instanceof(testItem, "InventoryContainer") then
            local targetContainerOption = context:insertOptionAfter(getText("IGUI_CraftUI_Favorite"), getText(
                "IGUI_ChooseDisassemblyInventory_TargetContainer"), testItem, makeTargetContainer, player)
            targetContainerOption.tooltip = getText("IGUI_ChooseDisassemblyInventory_TargetContainer_tooltip")
            local texture = getTexture("media/ui/RadioButtonCircle.png")
            local alreadyTarget = ChooseDisassemblyInventory:isTargetContainer(testItem)
            if alreadyTarget then
                targetContainerOption.notAvailable = true
                targetContainerOption.tooltip = getText("IGUI_ChooseDisassemblyInventory_IsTargetContainer_tooltip")
                texture = getTexture("media/ui/RadioButtonIndicator.png")
            end
            targetContainerOption.iconTexture = texture
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ChooseDisassemblyInventoryContextMenuEntry)
