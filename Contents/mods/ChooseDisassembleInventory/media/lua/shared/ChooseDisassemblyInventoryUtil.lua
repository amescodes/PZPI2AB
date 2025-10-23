if not ChooseDisassemblyInventoryUtil then
    ChooseDisassemblyInventoryUtil = {}
end

ChooseDisassemblyInventoryUtil.DefaultContainers = {'PlayerInventory', 'ItemSource'}

ChooseDisassemblyInventoryUtil.WhenToTransfer = {'AfterEach', 'AtEnd'}

function ChooseDisassemblyInventoryUtil.GetDefaultContainer(selectedItemContainer, playerInv)
    local defaultIndex = ChooseDisassemblyInventory.DefaultDestinationContainer
    if defaultIndex then
        local defOption = ChooseDisassemblyInventoryUtil.DefaultContainers[defaultIndex]
        if defOption == 'ItemSource' then
            return selectedItemContainer
        end
    end

    return playerInv
end

function ChooseDisassemblyInventoryUtil.AddWhenToTransferAction(previousAction, action)
    local whenToTransferIndex = ChooseDisassemblyInventory.WhenToTransferItems
    if whenToTransferIndex then
        local defOption = ChooseDisassemblyInventoryUtil.WhenToTransfer[whenToTransferIndex]
        if defOption == 'AfterEach' then
            ISTimedActionQueue.addAfter(previousAction, action)
            return action
        end
    end

    ISTimedActionQueue.add(action)
    return nil
end

function ChooseDisassemblyInventoryUtil.Print(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if (not debugOnly or ChooseDisassemblyInventory.Verbose) then
        print(txt)
    end
end

function ChooseDisassemblyInventoryUtil.GetCraftAction(recipe, queue)
    for i = #queue, 1, -1 do
        local action = queue[i]
        if action.recipe and action.jobType and action.jobType == recipe:getName() then
            return action
        end
    end
    return nil
end

function ChooseDisassemblyInventoryUtil.PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
    if queue then
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory: queue...", true)
        for i, action in ipairs(queue) do
            local jobType = action.jobType
            if not jobType then
                jobType = "???"
                local item = action.item:getFullType()
                ChooseDisassemblyInventoryUtil.Print("unknown job...item: " .. item, true)
            end
            ChooseDisassemblyInventoryUtil.Print(tostring(i) .. ") action: " .. jobType, true)
        end
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory: queue END ", true)
    end
end

function ChooseDisassemblyInventoryUtil.PrintArray(array)
    if array then
        for i = 0, array:size() - 1 do
            local s = array:get(i)
            ChooseDisassemblyInventoryUtil.Print(tostring(s), true)
        end
    end
end

function ChooseDisassemblyInventoryUtil.ShallowClone(array)
    local result = ArrayList.new()
    for i = 0, array:size() - 1 do
        result:add(array:get(i))
    end
    return result
end
