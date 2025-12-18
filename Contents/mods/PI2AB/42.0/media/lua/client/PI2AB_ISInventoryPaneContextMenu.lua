local old_ISInventoryPaneContextMenu_OnNewCraftComplete = ISInventoryPaneContextMenu.OnNewCraftComplete
ISInventoryPaneContextMenu_transferOnNewCraftComplete = function(args)
    old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)

    local playerObj = args.playerObj
    local playerInv = playerObj:getInventory()
    PI2ABUtil.PutInBag(playerObj, playerInv, args.container, PI2AB.getTargetContainer(playerObj), args.completedAction, playerInv:getItems(),args.recipe:getAllInputItems())
end

local ISWidgetHandCraftControl_onHandcraftActionCancelled = function(args)
    local action = args.completedAction
    if action then PI2ABComparer.remove(action.pi2ab_timestamp) end
end


local old_ISInventoryPaneContextMenu_OnNewCraft = ISInventoryPaneContextMenu.OnNewCraft
ISInventoryPaneContextMenu.OnNewCraft = function(selectedItem, recipe, player, all, eatPercentage)
    old_ISInventoryPaneContextMenu_OnNewCraft(selectedItem, recipe, player, all, eatPercentage)

    if PI2AB.Enabled then
        local playerObj = getSpecificPlayer(player)
        if not PI2ABUtil.IsAllowed(playerObj) then
            return
        end

        local playerInv = playerObj:getInventory()
        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe, queue)
            if action and action.containers then
                local logic = action.onCompleteTarget
                local args = PI2ABTransferArgs:new(logic,nil, action, logic:getRecipeData(), playerObj, selectedItem:getContainer(), action.containers, selectedItem,all)
                action:setOnComplete(ISInventoryPaneContextMenu_transferOnNewCraftComplete, args)
                action:setOnCancel(ISWidgetHandCraftControl_onHandcraftActionCancelled, args)
                local pi2ab_timestamp = os.time()
                action.pi2ab_timestamp = pi2ab_timestamp
                PI2ABComparer.create(pi2ab_timestamp, playerInv:getItems())
            end
        end
    end
end

-- possibly upcoming in future versions of the game?
--ISInventoryPaneContextMenu.OnNewCraftCompleteAll = function(completedAction, recipe, playerObj, containers, usedItems)
--end
