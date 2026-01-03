local old_ISInventoryPaneContextMenu_OnNewCraftComplete = ISInventoryPaneContextMenu.OnNewCraftComplete
local ISInventoryPaneContextMenu_transferOnNewCraftComplete = function(args)
    -- old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)

    if isServer() then
        old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)
        return
    end

    local timestamp = args.timestamp
    local player = getPlayer()
	local targetContainer = PI2ABCore.GetTargetContainer(player)
    local comparer = PI2ABComparer.get(timestamp)
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, args.sourceItemIds)
    
    -- if isClient() then
        --     PI2ABUtil.Print("ISInventoryPaneContextMenu_transferOnNewCraftComplete: CLIENT ON COMPLETE", true)
        
        --     -- PI2ABUtil.Delay(function()
        --     --     PI2ABCore.PutInBag(player, comparer.selectedItemContainer, targetContainer, itemIdsToTransfer)
        --     -- end,10)
        
        -- local targetContainerId = PI2AB.TargetContainer
    --     local tArgs = PI2ABServerTransferArgs:new(targetContainerId, args.selectedItemContainer,  itemIdsToTransfer,nil,nil)
    --     sendClientCommand(player,"PI2AB", "transferOnNewCraftComplete", tArgs)

    --     -- sendClientCommand(player,"PI2AB", "transferOnNewCraftComplete2", {timestamp = timestamp, sourceItemIds = itemIdsToTransfer})
    --     return
    -- end

    PI2ABCore.PutInBag(player, timestamp,args.selectedItemContainer, targetContainer, itemIdsToTransfer)
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end
    -- local player
    -- if isServer() then
    --     player = getPlayerByOnlineID(args.playerNum)
    --     sendServerCommand(player, "PI2AB", "transferOnNewCraftComplete", args)
    --     PI2ABUtil.Print("ISInventoryPaneContextMenu_transferOnNewCraftComplete: SERVER ON COMPLETE", true)
    -- else
    --     player = getSpecificPlayer(args.playerNum)
    --     if isClient() then
    --         PI2ABUtil.Print("ISInventoryPaneContextMenu_transferOnNewCraftComplete: CLIENT ON COMPLETE", true)
    --     else
    --         PI2ABUtil.Print("ISInventoryPaneContextMenu_transferOnNewCraftComplete: SP ON COMPLETE", true)
    --     end
    --     local targetContainer = PI2ABCore.GetTargetContainer(player)
    --     PI2ABCore.PutInBag(player, args.timestamp, args.selectedItemContainer, targetContainer, args.sourceItemIds)
    -- end
    PI2ABComparer.remove(timestamp)
    old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)
end

local ISInventoryPaneContextMenu_onHandcraftActionCancelled = function(args)
    local timestamp = args.timestamp
    if timestamp then PI2ABComparer.remove(timestamp) end
end

local old_ISInventoryPaneContextMenu_OnNewCraft = ISInventoryPaneContextMenu.OnNewCraft
ISInventoryPaneContextMenu.OnNewCraft = function(selectedItem, recipe, player, all, eatPercentage)
    old_ISInventoryPaneContextMenu_OnNewCraft(selectedItem, recipe, player, all, eatPercentage)

    local playerObj = getSpecificPlayer(player)
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(playerObj) then
        return
    end

    local playerInv = playerObj:getInventory()
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    if queue then
        local action,i= PI2ABUtil.GetCraftAction(recipe, queue)
        if action and action.containers then
            local logic = action.onCompleteTarget

            local recipeData = logic:getRecipeData()
            local sourceItems = recipeData:getAllKeepInputItems()
            local sourceItemIds = PI2ABUtil.GetItemIds(sourceItems)
            
            local pi2ab_timestamp = os.time()
            local args = PI2ABTransferArgs:new(logic,nil, recipe, selectedItem:getContainer(), action.containers, selectedItem, pi2ab_timestamp,sourceItemIds,all)
            action:setOnComplete(ISInventoryPaneContextMenu_transferOnNewCraftComplete, args)
            action:setOnCancel(ISInventoryPaneContextMenu_onHandcraftActionCancelled, args)
            
            local destroyItems = recipeData:getAllDestroyInputItems()
            local actionsToAddBack = {}
            while #queue > i do
                local addBackAction = queue[i+1]
                if addBackAction then
                    queueObj:removeFromQueue(addBackAction)

                    if addBackAction.Type == "ISInventoryTransferAction" and destroyItems:contains(addBackAction.item) then
                        --skip
                    else 
                        table.insert(actionsToAddBack,addBackAction)
                    end
                    -- if addBackAction.setAllowMissingItems then addBackAction:setAllowMissingItems(true) end

                end
            end
            PI2ABComparer.create(pi2ab_timestamp, actionsToAddBack, playerInv:getItems())

            local dummyAction = PI2ABDummyAction:new(playerObj, logic:getRecipe(), pi2ab_timestamp)
            ISTimedActionQueue.addAfter(action, dummyAction)
        end
    end
end

-- possibly upcoming in future versions of the game?
--ISInventoryPaneContextMenu.OnNewCraftCompleteAll = function(completedAction, recipe, playerObj, containers, usedItems)
