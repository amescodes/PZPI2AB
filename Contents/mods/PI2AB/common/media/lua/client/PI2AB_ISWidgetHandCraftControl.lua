function ISWidgetHandCraftControl:transferOnHandcraftActionComplete()
    local playerObj = self.player

    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB:getTargetContainer(playerObj)

    local l = self.logic
    local recipeData = l:getRecipeData()

    local completedAction = l:getCraftActionTable()
    local previousAction = completedAction

    self:onHandcraftActionComplete()

    local inputItems = recipeData:getAllInputItems()
    if inputItems then
        local allItems = playerInv:getItems()

        -- PI2ABUtil.Print("---------AFTER INVENTORY-----------")
        -- PI2ABUtil.PrintArray(allItems)
        -- PI2ABUtil.Print("---------------END-----------------")

        if completedAction.timestamp then
            local selectedItem = recipeData:getFirstInputItemWithFlag("Prop2")
            if not selectedItem then
                selectedItem = inputItems:get(inputItems:size() - 1)
            end
            local container = selectedItem:getContainer()

            local comparer = PI2ABComparer.get(completedAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems, inputItems)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local destinationContainer
                        if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
                            destinationContainer = targetContainer
                        else
                            local defContainer = PI2ABUtil.GetDefaultContainer(container, playerInv)
                            if defContainer and defContainer:hasRoomFor(playerObj, it) then
                                destinationContainer = defContainer
                            else
                                destinationContainer = playerInv
                            end
                        end

                        local action =
                            ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, action)
                        end
                    end
                end
            end
        end
    end
end

local old_ISWidgetHandCraftControl_startHandcraft = ISWidgetHandCraftControl.startHandcraft
function ISWidgetHandCraftControl:startHandcraft(force)
    old_ISWidgetHandCraftControl_startHandcraft(self, force)
    local playerObj = self.player
    if playerObj:HasTrait("Disorganized") then
        return
    end

    if PI2AB.Enabled then
        local recipeData = self.logic:getRecipeData()
        local recipe = recipeData:getRecipe()

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local ct = self.craftTimes
            for i = 0, ct - 1 do
                local action = PI2ABUtil.GetCraftAction(recipe, queue, i)
                if action then
                    local selectedItem = recipeData:getFirstInputItemWithFlag("Prop2")
                    if not selectedItem then
                        local inputItems = recipeData:getAllInputItems()
                        selectedItem = inputItems:get(inputItems:size() - 1)
                    end
                    action:setOnComplete(self.transferOnHandcraftActionComplete, self) -- , action, recipeData, playerObj, selectedItem:getContainer(), action.containers,selectedItem)
                    local timestamp = os.time()
                    action.timestamp = timestamp
                    PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
                end
            end
        end

        -- local previousAction = completedAction
        -- local src = recipe:getSource()
        -- if src then
        --     local allItems = playerInv:getItems()

        --     -- PI2ABUtil.Print("---------AFTER INVENTORY-----------")
        --     -- PI2ABUtil.PrintArray(allItems)
        --     -- PI2ABUtil.Print("---------------END-----------------")

        --     if completedAction.timestamp then
        --         local comparer = PI2ABComparer.get(completedAction.timestamp)
        --         if comparer then
        --             local itemsToTransfer = comparer:compare(allItems,src)
        --             if itemsToTransfer then
        --                 for i = 0, itemsToTransfer:size() - 1 do
        --                     local it = itemsToTransfer:get(i)
        --                     local destinationContainer
        --                     if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
        --                         destinationContainer = targetContainer
        --                     else
        --                         local defContainer = PI2ABUtil.GetDefaultContainer(container,playerInv)
        --                         if defContainer and defContainer:hasRoomFor(playerObj, it) then
        --                             destinationContainer = defContainer
        --                         else
        --                             destinationContainer = playerInv
        --                         end
        --                     end

        --                     local action = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
        --                     action:setAllowMissingItems(true)
        --                     if not action.ignoreAction then
        --                         previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, action)
        --                     end
        --                 end
        --             end
        --         end
        --     end
        -- end
    end
end

