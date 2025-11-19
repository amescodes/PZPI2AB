require "PI2ABComparer"

ISCraftingUI_transferOnCraftComplete = function(completedAction, recipe, playerObj, container,containers,all,ui)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local previousAction = completedAction
    local src = recipe:getSource()
    if src then
        local allItems = playerInv:getItems()

        if completedAction.timestamp then
            local comparer = PI2ABComparer.get(completedAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems,src)
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
        -- from ISCraftingUI:onCraftComplete B42.12.3
        if not RecipeManager.IsRecipeValid(recipe, playerObj, nil, containers) then return end
        local items = RecipeManager.getAvailableItemsNeeded(recipe, playerObj, containers, nil, nil)
        if items:isEmpty() then
            ui:refresh()
            return
        end
        local previousAction = completedAction
        local returnToContainer = {};
        if not recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= self.character:getInventory() then
                    local action = ISInventoryTransferUtil.newInventoryTransferAction(playerObj, item, item:getContainer(), playerInv, nil)
                    ISTimedActionQueue.addAfter(previousAction, action)
                    previousAction = action
                    table.insert(returnToContainer, item)
                end
            end
        end
        local action = ISCraftAction:new(self.character, items:get(0), recipe, container, containers)
        action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, container, containers,all,ui)
               
        local timestamp = os.time()
        action.timestamp = timestamp
        PI2ABComparer.create(timestamp,playerObj:getInventory():getItems())

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    else
        ui:refresh()
    end
end

local old_ISCraftingUI_craft = ISCraftingUI.craft
function ISCraftingUI:craft(button, all,_isWorkStation)
    old_ISCraftingUI_craft(self,button, all,_isWorkStation)

    if PI2AB.Enabled then
        local recipeListBox = self:getRecipeListBox()
        local recipe = recipeListBox.items[recipeListBox.selected].item.recipe
        local playerObj = self.character

        local itemsUsed = self:transferItems()
        local container = itemsUsed[1]:getContainer()

        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetCraftAction(recipe,queue)
            if action then
                action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj,container,self.containerList,all,self)
                
                local timestamp = os.time()
                action.timestamp = timestamp
                PI2ABComparer.create(timestamp,playerObj:getInventory():getItems())
            end
        end
    end
end