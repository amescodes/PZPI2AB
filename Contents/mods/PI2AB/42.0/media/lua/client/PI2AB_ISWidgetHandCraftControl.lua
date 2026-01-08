local ISWidgetHandCraftControl_transferOnHandcraftActionComplete = function(args)
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
    args.widget:onHandcraftActionComplete()
end

local ISWidgetHandCraftControl_onHandcraftActionCancelled = function(args)
    local timestamp = args.timestamp
    if timestamp then PI2ABComparer.remove(timestamp) end
    args.widget:onHandcraftActionCancelled()
end

local old_ISWidgetHandCraftControl_startHandcraft = ISWidgetHandCraftControl.startHandcraft
function ISWidgetHandCraftControl:startHandcraft(force)
    old_ISWidgetHandCraftControl_startHandcraft(self, force)

    local playerObj = self.player
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(playerObj) then
        return
    end
    
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    if queue then
        local ct = self.craftTimes
        local recipeData = self.logic:getRecipeData()
        
        local sourceItems = recipeData:getAllKeepInputItems()
        local sourceItemIds = PI2ABUtil.GetItemIds(sourceItems)

        local selectedItem = nil
        local destroyedItems = recipeData:getAllDestroyInputItems()
        if destroyedItems and destroyedItems:size() > 0 then
            selectedItem = destroyedItems:get(0)
        else
            local inputItems = recipeData:getAllInputItems()
            selectedItem = inputItems:get(inputItems:size() - 1)
        end

        for i = 0, ct - 1 do
            local action,j = PI2ABUtil.GetCraftAction(recipeData:getRecipe(), queue, i)
            if action then
                local timestamp = os.time() + i
                local args = PI2ABTransferArgs:new(playerObj:getPlayerNum(),nil,self, self.logic:getRecipe(), selectedItem:getContainer(), action.containers, selectedItem, timestamp,sourceItemIds)

                action:setOnComplete(ISWidgetHandCraftControl_transferOnHandcraftActionComplete, args)
                action:setOnCancel(ISWidgetHandCraftControl_onHandcraftActionCancelled, args);

                local actionsToAddBack
                if i == ct - 1 then
                    actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, recipeData, j)
                end

                PI2ABComparer.create(timestamp, actionsToAddBack, playerObj:getInventory():getItems())

                local dummyAction = PI2ABDummyAction:new(playerObj, timestamp)
                ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
    end
end

