local ISWidgetHandCraftControl_transferOnHandcraftActionComplete = function(args)
    local playerObj = args.playerObj
    local playerInv = playerObj:getInventory()
    PI2ABCore.PutInBag(playerObj, playerInv, args.container, PI2AB.getTargetContainer(playerObj), args.completedAction, playerInv:getItems(),args.recipe:getAllInputItems())
    args.widget:onHandcraftActionComplete()
end

local ISWidgetHandCraftControl_onHandcraftActionCancelled = function(args)
    local action = args.completedAction
    if action then PI2ABComparer.remove(action.pi2ab_timestamp) end
    args.widget:onHandcraftActionCancelled()
end

local old_ISWidgetHandCraftControl_startHandcraft = ISWidgetHandCraftControl.startHandcraft
function ISWidgetHandCraftControl:startHandcraft(force)
    old_ISWidgetHandCraftControl_startHandcraft(self, force)

    if PI2AB.Enabled then
        local playerObj = self.player
        if not PI2ABUtil.IsAllowed(playerObj) then
            return
        end

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local ct = self.craftTimes
            local recipeData = self.logic:getRecipeData()
            
            local selectedItem = nil            
            local destroyedItems = recipeData:getAllDestroyInputItems()
            if destroyedItems and destroyedItems:size() > 0 then
                selectedItem = destroyedItems:get(0)
            else
                local inputItems = recipeData:getAllInputItems()
                selectedItem = inputItems:get(inputItems:size() - 1)
            end

            for i = 0, ct - 1 do
                local action = PI2ABUtil.GetCraftAction(recipeData:getRecipe(), queue, i)
                if action then
                    local args = PI2ABTransferArgs:new(nil, self, action, recipeData, playerObj,
                        selectedItem:getContainer(), action.containers, selectedItem)

                    action:setOnComplete(ISWidgetHandCraftControl_transferOnHandcraftActionComplete, args)
                    action:setOnCancel(ISWidgetHandCraftControl_onHandcraftActionCancelled, args);

                    local pi2ab_timestamp = os.time() + i
                    action.pi2ab_timestamp = pi2ab_timestamp
                    PI2ABComparer.create(pi2ab_timestamp, playerObj:getInventory():getItems())
                end
            end
        end
    end
end

