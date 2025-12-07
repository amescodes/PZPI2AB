ISCraftingUI_transferOnCraftComplete = function(completedAction, recipe, playerObj, selectedItemContainer,container,containers,all)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local previousAction = completedAction
    local src = recipe:getSource()
    local itemsToTransfer
    if src then
        local allItems = playerInv:getItems()

        if completedAction.timestamp then
            local comparer = PI2ABComparer.get(completedAction.timestamp)
            if comparer then
                itemsToTransfer = comparer:compare(allItems,src)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local destinationContainer
                        if targetContainer and targetContainer:hasRoomFor(playerObj, it) then
                            destinationContainer = targetContainer
                        else
                            local defContainer = PI2ABUtil.GetDefaultContainer(container,playerInv)
                            if defContainer and defContainer:hasRoomFor(playerObj, it) then
                                destinationContainer = defContainer
                            else
                                destinationContainer = playerInv
                            end
                        end

                        local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(),
                        destinationContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, action)
                        end
                    end
                end
            end
        end
    end

    if all then
        -- from ISCraftingUI:onCraftComplete
        if not RecipeManager.IsRecipeValid(recipe, playerObj, nil, containers) then return end
        local items = RecipeManager.getAvailableItemsNeeded(recipe, playerObj, containers, nil, nil)
        if items:isEmpty() then
            ui:refresh()
            return
        end
        
        if previousAction == nil then
            previousAction = completedAction
        end
        
        local returnToContainer = {}
        if not recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerInv then
                    local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), playerInv, nil)
                    ISTimedActionQueue.addAfter(previousAction, action)
                    previousAction = action
                    table.insert(returnToContainer, item)
                end
            end
        end

        local action = ISCraftAction:new(playerObj, items:get(0), recipe:getTimeToMake(), recipe, container, containers)
        action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer, container,containers,all)
        
        local timestamp = os.time()
        action.timestamp = timestamp
        PI2ABComparer.create(timestamp,playerInv:getItems(),itemsToTransfer)

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    end
end

local old_ISCraftingUI_craft = ISCraftingUI.craft
function ISCraftingUI:craft(button, all)
    old_ISCraftingUI_craft(self,button, all)

    if PI2AB.Enabled then
        local recipeListBox = self:getRecipeListBox()
        local recipe = recipeListBox.items[recipeListBox.selected].item.recipe
        local playerObj = self.character

        local itemsUsed = self:transferItems()
        local container = itemsUsed[1]:getContainer()
        local selectedItemContainer = container
        if not recipe:isCanBeDoneFromFloor() then
            container = playerObj:getInventory()
        end

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe,queue)
            if action then
                action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj,selectedItemContainer,container,self.containerList,all)
                
                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp,playerObj:getInventory():getItems())
            end
        end
    end
end