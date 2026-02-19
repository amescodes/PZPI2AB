local old_ISInventoryPaneContextMenu_OnNewCraftComplete = ISInventoryPaneContextMenu.OnNewCraftComplete
local ISInventoryPaneContextMenu_transferOnNewCraftComplete = function(args)
    old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)

    if isServer() then return end

    local timestamp = args.timestamp
    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end

    local player = getSpecificPlayer(args.playerNum)    
    local allItems = player:getInventory():getItems()
    
    local itemIdsToTransfer = comparer:compare(allItems, args.sourceItemIds)
	local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBag(player, timestamp,args.selectedItemContainer, targetContainer, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end
    
    PI2ABComparer.remove(timestamp)
end

local ISInventoryPaneContextMenu_onHandcraftActionCancelled = function(args)
    local timestamp = args.timestamp
    if timestamp then PI2ABComparer.remove(timestamp) end
end

local old_ISInventoryPaneContextMenu_OnNewCraft = ISInventoryPaneContextMenu.OnNewCraft
ISInventoryPaneContextMenu.OnNewCraft = function(selectedItem, recipe, player, all, eatPercentage)
    old_ISInventoryPaneContextMenu_OnNewCraft(selectedItem, recipe, player, all, eatPercentage)

    local playerObj = getSpecificPlayer(player)
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(playerObj) or recipe:getCategory() == 'Cooking' then return end

    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    if queue then
        local action,i= PI2ABUtil.GetCraftActionDesc(recipe, queue)
        if action then
            local logic = action.onCompleteTarget

            local recipeData = logic:getRecipeData()
            local sourceItems = recipeData:getAllKeepInputItems()
            local sourceItemIds = PI2ABUtil.GetItemIds(sourceItems)
            
            local timestamp = os.time()
            local args = PI2ABTransferArgs:new(player,logic,nil, recipe, selectedItem:getContainer(), action.containers, selectedItem, timestamp,sourceItemIds,all)
            action:setOnComplete(ISInventoryPaneContextMenu_transferOnNewCraftComplete, args)
            action:setOnCancel(ISInventoryPaneContextMenu_onHandcraftActionCancelled, args)
            
            local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, recipeData, i)
            PI2ABComparer.create(timestamp, actionsToAddBack, playerObj:getInventory():getItems())

            local dummyAction = PI2ABDummyAction:new(playerObj, timestamp)
            ISTimedActionQueue.addAfter(action, dummyAction)
        end
    end
end

-- possibly upcoming in future versions of the game?
--ISInventoryPaneContextMenu.OnNewCraftCompleteAll = function(completedAction, recipe, playerObj, containers, usedItems)
