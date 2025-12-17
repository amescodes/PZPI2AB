local ISWidgetHandCraftControl_transferOnHandcraftActionComplete = function(args)
    local playerObj = args.playerObj
    local playerInv = playerObj:getInventory()
    -- local result = PI2ABUtil.PutInBagRecipe(playerObj,playerInv,args.container,targetContainer,completeAction, args.recipe)
    PI2ABUtil.PutInBag(playerObj, playerInv, args.container, PI2AB.getTargetContainer(playerObj), args.completedAction, playerInv:getItems(),args.recipe:getAllInputItems())
    -- local previousAction = result.previousAction
    -- local completedAction = result.completedAction
    -- local targetContainer = PI2AB.getTargetContainer(playerObj)
    -- local completedAction = args.completedAction

    -- local inputItems = args.recipe:getAllInputItems()
    -- if inputItems then
    --     local allItems = playerInv:getItems()

    --     if completedAction.timestamp then
    --         local comparer = PI2ABComparer.get(completedAction.timestamp)
    --         if comparer then
    --             local itemsToTransfer = comparer:compare(allItems, inputItems)
    --             if itemsToTransfer then
    --                 for i = 0, itemsToTransfer:size() - 1 do
    --                     local it = itemsToTransfer:get(i)
    --                     local destinationContainer
    --                     if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
    --                         destinationContainer = targetContainer
    --                     else
    --                         local defContainer = PI2ABUtil.GetDefaultContainer(args.container, playerInv)
    --                         if defContainer and defContainer:hasRoomFor(playerObj, it) then
    --                             destinationContainer = defContainer
    --                         else
    --                             destinationContainer = playerInv
    --                         end
    --                     end

    --                     local action =
    --                         ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
    --                     action:setAllowMissingItems(true)
    --                     if not action.ignoreAction then
    --                         PI2ABUtil.AddWhenToTransferAction2(ISTimedActionQueue.getTimedActionQueue(playerObj), action)
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    args.widget:onHandcraftActionComplete()
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
                if destroyedItems and not destroyedItems == 0 then
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
                    local timestamp = os.time() + i
                    action.timestamp = timestamp
                    PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
                end
            end
        end
    end
end

