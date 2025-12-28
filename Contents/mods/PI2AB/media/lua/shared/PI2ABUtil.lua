if not PI2ABUtil then
    PI2ABUtil = {}
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

        if action.vehicle and action.part and action.jobType
            and action.jobType == getText("Tooltip_Vehicle_Uninstalling", action.part:getInventoryItem():getDisplayName())then
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

function PI2ABUtil.GetDismantleAction(queue)
    for i = 1, #queue do
        local action = queue[i]

        if action.vehicle then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetCraftAction(recipe, queue)
    for i = 1, #queue do
        local action = queue[i]

        if (action.recipe and action.jobType and action.jobType == recipe:getName()) or (action.craftRecipe and action.craftRecipe == recipe) then
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
    if source then
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

function PI2ABUtil.GetActualItemsFromMoveablesSource(playerInv,source)
    local actualItems = ArrayList.new()
    if source then
        for k = 0, source:size() - 1 do
            local srcItem = source:get(k)
            local actualItem = playerInv:FindAndReturn(srcItem)
            if actualItem then actualItems:add(actualItem) end
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
    for dy=-1,1 do
        for dx=-1,1 do
            local sq = getCell():getGridSquare(cx + dx, cy + dy, cz)
            if sq then
                table.insert(sqs, sq)
            end
        end
    end

    local items = ArrayList.new()
    
    -- items on square
    local wobs = square:getWorldObjects()
    for i = 0, wobs:size()-1 do
        local o = wobs:get(i)
        if o then
            local item = o:getItem()
            if item and not items:contains(item) then items:add(item) end
        end
    end
    -- items on surrounding squares
    for _,gs in ipairs(sqs) do
        -- stop grabbing thru walls...
        if gs ~= square and square and square:isBlockedTo(gs) then
            gs = nil
        end

        if gs ~= nil then
            local wobs = gs:getWorldObjects()
            for i = 0, wobs:size()-1 do
                local o = wobs:get(i)
                if o then
                    local item = o:getItem()
                    if item and not items:contains(item) then items:add(item) end
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

function PI2ABUtil.Round(number)
    return ItemContainer.floatingPointCorrection(number)
end