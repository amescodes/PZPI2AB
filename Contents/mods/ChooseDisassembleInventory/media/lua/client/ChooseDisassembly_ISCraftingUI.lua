require "ChooseDisassemblyInventoryUtil"
require "ChooseDisassemblyInventoryComparer"

ISCraftingUI_transferOnCraftComplete = function(completedAction, recipe, playerObj, container,containers,all,ui)
    local targetContainer = ChooseDisassemblyInventory:getTargetContainer(playerObj)
    local destinationContainer
    if targetContainer then
        destinationContainer = targetContainer
    end
    if not destinationContainer then
        destinationContainer = container
    end

    local previousAction = completedAction
    local src = recipe:getSource()
    if src then
        local playerInv = playerObj:getInventory()
        local allItems = playerInv:getItems()

        ChooseDisassemblyInventoryUtil.Print("---------AFTER INVENTORY-----------")
        ChooseDisassemblyInventoryUtil.PrintArray(allItems)
        ChooseDisassemblyInventoryUtil.Print("---------------END-----------------")

        if completedAction.timestamp then
            local comparer = ChooseDisassemblyInventoryComparer.get(completedAction.timestamp)
            if comparer then
                local itemsToTransfer = comparer:compare(allItems,src)
                if itemsToTransfer then
                    for i = 0, itemsToTransfer:size() - 1 do
                        local it = itemsToTransfer:get(i)
                        local finalDestContainer
                        if destinationContainer:hasRoomFor(playerObj, it) then
                            finalDestContainer = destinationContainer
                        else
                            finalDestContainer = playerInv
                        end

                        local action = ISInventoryTransferAction:new(playerObj, it, playerObj:getInventory(),
                        finalDestContainer, nil)
                        action:setAllowMissingItems(true)
                        if not action.ignoreAction then
                            ISTimedActionQueue.addAfter(completedAction, action)
                        end
                        previousAction = action
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
        local returnToContainer = {};
        if not recipe:isCanBeDoneFromFloor() then
            for i=1,items:size() do
                local item = items:get(i-1)
                if item:getContainer() ~= playerObj:getInventory() then
                    local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), playerObj:getInventory(), nil)
                    ISTimedActionQueue.addAfter(previousAction, action)
                    previousAction = action
                    table.insert(returnToContainer, item)
                end
            end
        end

        local action = ISCraftAction:new(playerObj, items:get(0), recipe:getTimeToMake(), recipe, container, containers)
        action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj, container,containers,all,ui)
        
        local timestamp = os.time()
        action.timestamp = timestamp
        ChooseDisassemblyInventoryComparer.create(timestamp,playerObj:getInventory():getItems())

        ISTimedActionQueue.addAfter(previousAction, action)
        ISCraftingUI.ReturnItemsToOriginalContainer(playerObj, returnToContainer)
    end
end

local old_ISCraftingUI_craft = ISCraftingUI.craft
function ISCraftingUI:craft(button, all)
    old_ISCraftingUI_craft(self,button, all)

    if ChooseDisassemblyInventory.Enabled then

        self.craftInProgress = false
        local recipeListBox = self:getRecipeListBox()
        local selectedItem = recipeListBox.items[recipeListBox.selected].item;
        local recipe = selectedItem.recipe
        local src = recipe:getSource()
        if src then
            local playerObj = self.character
            local playerInv = playerObj:getInventory()

            local itemsUsed = self:transferItems()
            local container = itemsUsed[1]:getContainer()

            ChooseDisassemblyInventoryUtil.Print("---------BEFORE INVENTORY-----------")
            ChooseDisassemblyInventoryUtil.PrintArray(playerInv:getItems())
            ChooseDisassemblyInventoryUtil.Print("---------------END------------------")

            local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
            local count = #queue;
            if queue and count then
                local action = queue[count]
                action:setOnComplete(ISCraftingUI_transferOnCraftComplete, action, recipe, playerObj,container,self.containerList,all,self)
                
                local timestamp = os.time()
                action.timestamp = timestamp
                ChooseDisassemblyInventoryComparer.create(timestamp,playerInv:getItems())
            end
            -- end
        end
    end
end