if not PI2ABUtil then
    PI2ABUtil = {}
end

PI2ABUtil.DefaultContainers = {'PlayerInventory', 'ItemSource'}

PI2ABUtil.WhenToTransfer = {'AfterEach', 'AtEnd'}

function PI2ABUtil.GetDefaultContainer(selectedItemContainer, playerInv)
    local defaultIndex = PI2AB.DefaultDestinationContainer
    if defaultIndex then
        local defOption = PI2ABUtil.DefaultContainers[defaultIndex]
        if defOption == 'ItemSource' then
            return selectedItemContainer
        end
    end

    return playerInv
end

function PI2ABUtil.AddWhenToTransferAction(previousAction, action)
    local whenToTransferIndex = PI2AB.WhenToTransferItems
    if whenToTransferIndex then
        local defOption = PI2ABUtil.WhenToTransfer[whenToTransferIndex]
        if defOption == 'AfterEach' then
            ISTimedActionQueue.addAfter(previousAction, action)
            return action
        end
    end

    ISTimedActionQueue.add(action)
    return nil
end

function PI2ABUtil.AddWhenToTransferAction2(queue, action)
    local whenToTransferIndex = PI2AB.WhenToTransferItems
    if whenToTransferIndex then
        local defOption = PI2ABUtil.WhenToTransfer[whenToTransferIndex]
        if defOption == 'AfterEach' then
            --ISTimedActionQueue.addAfter(previousAction, action)
            table.insert(queue.queue, 1, action)
            queue.current = action
            action:begin()
            return action
        end
    end

    queue:addToQueue(action)
    return nil
end

function PI2ABUtil.GetCraftAction(recipe, queue)
    for i = 1, #queue do
        local action = queue[i]

        if action.recipe and action.jobType and action.jobType == recipe:getName() then
            return action
        end

        -- from craft menu
        if action.craftRecipe and action.craftRecipe == recipe then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetCraftActionDesc(recipe, queue)
    for i = #queue, 1, -1 do
        local action = queue[i]
        if action.recipe and action.jobType and action.jobType == recipe:getName() then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetActualItemsFromSource(playerInv,source)
    local actualItems = ArrayList.new()
    if source and source:size() > 0 then
        for j = 0, source:size() - 1 do
            local recipeSource = source:get(j)
            if recipeSource:isKeep() then
                local srcItems = recipeSource:getItems()
                for k = 0, srcItems:size() - 1 do
                    local srcItem = srcItems:get(k)
                    local actualItem = playerInv:FindAndReturn(srcItem)
                    if actualItem then actualItems:add(actualItem) end
                end
            end
        end
    end
    return actualItems
end

function PI2ABUtil.Print(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if (not debugOnly or PI2AB.Verbose) then
        print(txt)
    end
end

function PI2ABUtil.PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
    if queue then
        PI2ABUtil.Print("PI2AB: queue...", true)

        for i, action in ipairs(queue) do
            local jobType = action.jobType
            if not jobType then
                local destContainer = action.destContainer
                local srcContainer = action.srcContainer
                if destContainer or srcContainer then
                    local item = action.item:getFullType()
                    jobType = "Transfer "..tostring(item).." ("..action.item:getID()..") from " .. tostring(srcContainer:getType()) .. " to " .. tostring(destContainer:getType())
                    PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType, true)
                else
                    jobType = "???"
                    local item = action.item:getFullType()
                    PI2ABUtil.Print(tostring(i) .. ") unknown job...item: " .. item, true)
                end
            else
                PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType.." (item id: "..action.item:getID()..")", true)
            end
        end

        PI2ABUtil.Print("PI2AB: queue END ", true)
    end
end

function PI2ABUtil.PrintArray(array)
    if array then
        for i = 0, array:size() - 1 do
            local s = array:get(i)
            PI2ABUtil.Print(tostring(s), true)
        end
    end
end

function PI2ABUtil.PrintTable(table)
    if table then
        for k, v in pairs(table) do
            PI2ABUtil.Print(tostring(k) .. ": " .. tostring(v), true)
        end
    end
end

function PI2ABUtil.ShallowClone(array)
    local result = ArrayList.new()
    for i = 0, array:size() - 1 do
        result:add(array:get(i))
    end
    return result
end
