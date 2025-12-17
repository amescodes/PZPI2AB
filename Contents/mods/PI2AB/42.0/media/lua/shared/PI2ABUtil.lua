if not PI2ABUtil then
    PI2ABUtil = {}
end

PI2ABUtil.DefaultContainers = {'PlayerInventory', 'ItemSource'}

PI2ABUtil.WhenToTransfer = {'AfterEach', 'AtEnd'}

function PI2ABUtil.PutInBagRecipe(playerObj, playerInv, selectedItemContainer, targetContainer, completedAct, recipe,handcraft)
    local src = recipe:getSource()
    local itemsToTransfer
    local result
    if src then
        local srcItems = PI2ABUtil.GetActualItemsFromSource(playerInv, src)
        local allItems = playerInv:getItems()
        if completedAct.timestamp then
            result = PI2ABUtil.PutInBag(playerObj, playerInv, selectedItemContainer, targetContainer, completedAct,
                allItems, srcItems,handcraft)
        end
    end

    return result or PI2ABResult:new(nil, completedAct, itemsToTransfer)
end

function PI2ABUtil.PutInBag(playerObj, playerInv, selectedItemContainer, targetContainer, completedAct, allItems,
    srcItems,handcraft)
    local comparer = PI2ABComparer.get(completedAct.timestamp)
    local previousAct = completedAct
    local targetWeightTransferred = 0.0
    local defWeightTransferred = 0.0
    local itemsToTransfer
    if comparer then
        itemsToTransfer = comparer:compare(allItems, srcItems)
        -- target container
        local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
        PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
        local tWeight = targetContainer and targetContainer:getContentsWeight() or 0
        targetWeightTransferred = comparer.targetWeightTransferred
        local runningBagWeight = targetContainer and PI2ABUtil.Round(tWeight + targetWeightTransferred) or 0
        PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
        -- backup / default container
        local defContainer = PI2ABUtil.GetDefaultContainer(selectedItemContainer, playerInv)
        local bCapacity = defContainer and defContainer:getCapacity() or 0
        PI2ABUtil.Print("default container capacity " .. tostring(bCapacity), true)
        local bWeight = defContainer and defContainer:getContentsWeight() or 0
        defWeightTransferred = comparer.defWeightTransferred
        local bRunningBagWeight = defContainer and PI2ABUtil.Round(bWeight + defWeightTransferred) or 0
        PI2ABUtil.Print("default container contents weight START " .. tostring(bRunningBagWeight), true)
        -- check new items and queue transfer actions
        for i = 0, itemsToTransfer:size() - 1 do
            local it = itemsToTransfer:get(i)
            local itemWeight = it:getWeight()
            PI2ABUtil.Print("itemWeight: " .. tostring(itemWeight), true)
            local destinationContainer
            local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
            if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                runningBagWeight = possibleNewWeight
                targetWeightTransferred = PI2ABUtil.Round(targetWeightTransferred + itemWeight)
                destinationContainer = targetContainer
            else
                possibleNewWeight = PI2ABUtil.Round(bRunningBagWeight + itemWeight)
                if defContainer then
                    PI2ABUtil.Print("default container possibleNewWeight: " .. tostring(possibleNewWeight), true)
                    if defContainer:getType() ~= "floor" then
                        if defContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= bCapacity then
                            bRunningBagWeight = possibleNewWeight
                            defWeightTransferred = PI2ABUtil.Round(defWeightTransferred + itemWeight)
                        end
                    end

                    destinationContainer = defContainer
                else
                    destinationContainer = playerInv
                end
            end

            if destinationContainer then
                local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                tAction:setAllowMissingItems(true)
                if not tAction.ignoreAction then
                    previousAct = PI2ABUtil.AddWhenToTransferAction(previousAct, tAction)
                end
            end
        end

        PI2ABComparer.remove(completedAct.timestamp)
    end
    return PI2ABResult:new(previousAct, completedAct, itemsToTransfer, targetWeightTransferred, defWeightTransferred)
end

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
            local result = ISTimedActionQueue.addAfter(previousAction, action)
            if result then
                return action
            else
                local queue = ISTimedActionQueue.getTimedActionQueue(previousAction.character)
                table.insert(queue.queue, 1, action)
                queue.current = action
                action:begin()
                return action
            end
        end
    end
    
    ISTimedActionQueue.getTimedActionQueue(previousAction.character):addToQueue(action)
    return nil
end

function PI2ABUtil.GetMovablesAction(queue)
    for i = 1, #queue do
        local action = queue[i]

        if action.mode and action.moveProps and action.mode == "scrap" then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetUninstallVehiclePartAction(queue)
    for i = 1, #queue do
        local action = queue[i]

        if action.vehicle and action.part then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetRemoveBurntVehicleAction(queue)
    for i = 1, #queue do
        local action = queue[i]

        if action.vehicle then
            return action
        end
    end
    return nil
end


function PI2ABUtil.GetCraftAction(recipe, queue, skipCt)
    if not skipCt then
        skipCt = 0
    end

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
    end
    return nil
end

function PI2ABUtil.GetActualItemsFromSource(playerInv, source)
    local actualItems = ArrayList.new()
    if source and source:size() > 0 then
        for j = 0, source:size() - 1 do
            local recipeSource = source:get(j)
            if recipeSource:isKeep() then
                local srcItems = recipeSource:getItems()
                for k = 0, srcItems:size() - 1 do
                    local srcItem = srcItems:get(k)
                    local actualItem = playerInv:FindAndReturn(srcItem)
                    if actualItem then
                        actualItems:add(actualItem)
                    end
                end
            end
        end
    end
    return actualItems
end

function PI2ABUtil.IsAllowed(playerObj)
    -- todo add sandbox setting
    -- if playerObj:hasTrait(CharacterTrait.DISORGANIZED) then return end
    -- b41: if playerObj:HasTrait("Disorganized") then
    --     return false
    -- end
    return true
end

function PI2ABUtil.GetActualItemsFromMoveablesSource(playerInv, source)
    local actualItems = ArrayList.new()
    if source and source:size() > 0 then
        for k = 0, source:size() - 1 do
            local srcItem = source:get(k)
            local actualItem = playerInv:FindAndReturn(srcItem)
            if actualItem then
                actualItems:add(actualItem)
            end
        end
    end
    return actualItems
end

-- from ISInventoryPage:refreshBackpacks()
function PI2ABUtil.GetObjectsOnAndAroundSquare(square)
    local cx = square:getX()
    local cy = square:getY()
    local cz = square:getZ()
    local sqs = {}
    for dy = -1, 1 do
        for dx = -1, 1 do
            local sq = getCell():getGridSquare(cx + dx, cy + dy, cz)
            if sq then
                table.insert(sqs, sq)
            end
        end
    end

    local items = ArrayList.new()

    -- items on square
    local wobs = square:getWorldObjects()
    for i = 0, wobs:size() - 1 do
        local o = wobs:get(i)
        if o then
            local item = o:getItem()
            if item then
                items:add(item)
            end
        end
    end
    -- items on surrounding squares
    for _, gs in ipairs(sqs) do
        -- stop grabbing thru walls...
        if gs ~= square and square and square:isBlockedTo(gs) then
            gs = nil
        end

        if gs ~= nil then
            local wobs = gs:getWorldObjects()
            for i = 0, wobs:size() - 1 do
                local o = wobs:get(i)
                if o then
                    local item = o:getItem()
                    if item then
                        items:add(item)
                    end
                end
            end
        end
    end
    return items
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
                    jobType = "Transfer " .. tostring(item) .. " (" .. action.item:getID() .. ") from " ..
                                  tostring(srcContainer:getType()) .. " to " .. tostring(destContainer:getType())
                    PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType, true)
                else
                    jobType = "???"
                    local item = action.item:getFullType()
                    PI2ABUtil.Print(tostring(i) .. ") unknown job...item: " .. item, true)
                end
            else
                PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType .. " (item id: " .. action.item:getID() .. ")",
                    true)
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

function PI2ABUtil.Round(number)
    return ItemContainer.floatingPointCorrection(number)
end
