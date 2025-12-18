local ISWidgetHandCraftControl_transferOnHandcraftActionComplete = function(args)
    local playerObj = args.playerObj
    local playerInv = playerObj:getInventory()
    PI2ABUtil.PutInBag(playerObj, playerInv, args.container, PI2AB.getTargetContainer(playerObj), args.completedAction, playerInv:getItems(),args.recipe:getAllInputItems())
    args.widget:onHandcraftActionComplete()
end

local ISWidgetHandCraftControl_onHandcraftActionCancelled = function(args)
    local action = args.completedAction
    if action then PI2ABComparer.remove(action.timestamp) end
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
            local selectedItem = recipeData:getFirstInputItemWithFlag("Prop2")
            if not selectedItem then
                local destroyedItems = recipeData:getAllDestroyInputItems()
                if destroyedItems and not destroyedItems:size() == 0 then
                    selectedItem = destroyedItems:get(0)
                else
                    local inputItems = recipeData:getAllInputItems()
                    selectedItem = inputItems:get(0)
                end
            end

            for i = 0, ct - 1 do
                local action = PI2ABUtil.GetCraftAction(recipeData:getRecipe(), queue, i)
                if action then
                    local args = PI2ABTransferArgs:new(nil, self, action, recipeData, playerObj,
                        selectedItem:getContainer(), action.containers, selectedItem)

                    action:setOnComplete(ISWidgetHandCraftControl_transferOnHandcraftActionComplete, args)
                    action:setOnCancel(ISWidgetHandCraftControl_onHandcraftActionCancelled, args);

                    local timestamp = os.time() + i
                    action.timestamp = timestamp
                    PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
                end
            end
        end
    end
end

