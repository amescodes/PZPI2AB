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


function PI2ABUtil.AddWhenToTransferActionHandcraft(queue, action)
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

function PI2ABUtil.Print(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if (not debugOnly or PI2AB.Verbose) then
        print(txt)
    end
end

function PI2ABUtil.GetCraftAction(recipe, queue,skipCt)
    if not skipCt then skipCt = 0 end
    
    local skips = 0
    for i = 1, #queue do
        local action = queue[i]

        if action.recipe and action.jobType and action.jobType == recipe:getName() then
            if skips >= skipCt then
                return action
            end
        end
        
        -- from craft menu
        if action.craftRecipe and action.craftRecipe == recipe then
            if skips >= skipCt then
                return action
            end
        end

        skips = skips + 1
    end
    return nil
end

function PI2ABUtil.GetCraftActionDesc(recipe, queue)
    for i = #queue, 1, -1 do
        local action = queue[i]

        if action.recipe and action.jobType and action.jobType == recipe:getName() then
            return action
        end

        if action.craftRecipe and action.craftRecipe == recipe then
            return action
        end
    end
    return nil
end

function PI2ABUtil.PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
    if queue then
        PI2ABUtil.Print("PI2AB: queue...", true)
        for i, action in ipairs(queue) do
            local jobType = action.Type
            if not jobType then
                jobType = "???"
                local item = action.item:getFullType()
                PI2ABUtil.Print("unknown job...item: " .. item, true)
            end
            PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType, true)
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

function PI2ABUtil.ShallowClone(array)
    local result = ArrayList.new()
    for i = 0, array:size() - 1 do
        result:add(array:get(i))
    end
    return result
end
