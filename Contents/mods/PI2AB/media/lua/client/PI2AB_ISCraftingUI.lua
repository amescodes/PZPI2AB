ISCraftingUI_transferOnCraftComplete = function(completeAction, recipe, playerObj, selectedItemContainer,container,containers,all,ui)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local result = PI2ABCore.PutInBagRecipe(playerObj,playerInv,selectedItemContainer,targetContainer,completeAction, recipe)
    local previousAction = result.previousAction
    local completedAction = result.completedAction

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
        action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj, selectedItemContainer, container,containers,all,ui)
        
        local timestamp = os.time()
        action.pi2ab_timestamp = timestamp
        PI2ABComparer.create(timestamp,playerInv:getItems(),result.itemsToTransfer,result.targetWeightTransferred,result.defWeightTransferred)

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    end
end

local old_ISCraftingUI_craft = ISCraftingUI.craft
function ISCraftingUI:craft(button, all)
    old_ISCraftingUI_craft(self,button, all)

    if PI2AB.Enabled then        
        local playerObj = self.character
        if not PI2AB.IsAllowed(playerObj) then
            return
        end

        local recipeListBox = self:getRecipeListBox()
        local recipe = recipeListBox.items[recipeListBox.selected].item.recipe

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
                action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj,selectedItemContainer,container,self.containerList,all,self)
                
                local timestamp = os.time()
                action.pi2ab_timestamp = timestamp
                PI2ABComparer.create(timestamp,playerObj:getInventory():getItems())
            end
        end
    end
end