local old_ISInventoryPaneContextMenu_OnNewCraftComplete = ISInventoryPaneContextMenu.OnNewCraftComplete
local ISInventoryPaneContextMenu_transferOnNewCraftComplete = function(args)
    old_ISInventoryPaneContextMenu_OnNewCraftComplete(args.logic)

    local playerObj = args.playerObj
    -- if isServer() then
    --     sendServerCommand(playerObj, 'PI2AB', 'transferOnCraftComplete', { completedAction = args.completedAction, container = args.container, recipe = args.recipe })
    --     return
    -- end

    local playerInv = playerObj:getInventory()
    PI2ABCore.PutInBag(playerObj, playerInv, args.container, PI2ABCore.GetTargetContainer(playerObj), args.completedAction, playerInv:getItems(),args.recipe:getAllKeepInputItems())
end

local ISInventoryPaneContextMenu_onHandcraftActionCancelled = function(args)
    local action = args.completedAction
    if action then PI2ABComparer.remove(action.pi2ab_timestamp) end
end

local function queueDummy(playerObj, action, timestamp)
    local dummyAction = PI2ABDummyAction:new(playerObj, timestamp)
    ISTimedActionQueue.addAfter(action, dummyAction)
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
                action:setOnCancel(ISInventoryPaneContextMenu_onHandcraftActionCancelled, args)
              
                local pi2ab_timestamp = os.time()
                action.pi2ab_timestamp = pi2ab_timestamp
                PI2ABComparer.create(pi2ab_timestamp, playerInv:getItems())

                -- local dummyAction = PI2ABDummyAction:new(playerObj, pi2ab_timestamp)
                ISTimedActionQueue.queueActions(playerObj, queueDummy, action)
                -- ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
    end
end

-- possibly upcoming in future versions of the game?
--ISInventoryPaneContextMenu.OnNewCraftCompleteAll = function(completedAction, recipe, playerObj, containers, usedItems)
--end
