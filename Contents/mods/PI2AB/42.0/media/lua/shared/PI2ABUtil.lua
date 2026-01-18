if not PI2ABUtil then
    PI2ABUtil = {}
end

function PI2ABUtil.GetMovablesAction(queue)
    for i = 1, #queue do
        local action = queue[i]
        if action.Type == "ISMoveablesAction" and action.mode == "scrap" then
            return action,i
        end
    end
    return nil
end

function PI2ABUtil.GetTakeEnginePartsAction(queue)
    for i = 1, #queue do
        local action = queue[i]
        if action.Type == "ISTakeEngineParts" then
            return action,i
        end
    end
    return nil
end

function PI2ABUtil.GetUninstallVehiclePartAction(queue)
    for i = 1, #queue do
        local action = queue[i]        
        if action.Type == "ISUninstallVehiclePart" then
            return action,i
        end
    end
    return nil
end

function PI2ABUtil.GetRemoveBurntVehicleAction(queue)
    for i = 1, #queue do
        local action = queue[i]
        if action.Type == "ISRemoveBurntVehicle" then
            return action,i
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
        if action.Type == "ISHandcraftAction" and action.craftRecipe == recipe then
            if skips >= skipCt then
                return action,i
            else
                skips = skips + 1
            end
        end

        -- -- from craft menu
        -- if action.craftRecipe and action.craftRecipe == recipe then
        --     if skips >= skipCt then
        --         return action
        --     else
        --         skips = skips + 1
        --     end
        -- end
    end
    return nil
end

function PI2ABUtil.GetCraftActionDesc(recipe, queue)
    for i = #queue, 1, -1 do
        local action = queue[i]
        if action.Type == "ISHandcraftAction" and action.craftRecipe == recipe then
            return action,i
        end
    end
    return nil
end

function PI2ABUtil.GetDummyAction(queue, timestamp)
    for i = 1, #queue do
        local action = queue[i]
        if action.Type == "PI2ABDummyAction" and action.pi2ab_timestamp == timestamp then
            return action
        end
    end
    return nil
end

function PI2ABUtil.GetUniqueId(suff)
    local suffix = ''
    if suff then
        suffix = "_" .. tostring(suff)
    end
    return string.sub(os.time(),-16)..suffix
end

function PI2ABUtil.GetMoveableUniqueId(obj,sq)
    local spriteId = obj:getSprite():getID()

    local x = sq:getX()
    local y = sq:getY()
    local z = sq:getZ()

    return spriteId .. "_" .. x .. "_" .. y .. "_" .. z
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

function PI2ABUtil.GetAddBackActionsFromQueue(queueObj, recipeData, startIndex)    
    local queue = queueObj.queue
    local destroyItems = recipeData and recipeData:getAllDestroyInputItems() or nil
    local actionsToAddBack = {}
    while #queue > startIndex do
        local addBackAction = queue[startIndex+1]
        if addBackAction then
            queueObj:removeFromQueue(addBackAction)
            if not (addBackAction.Type == "ISInventoryTransferAction" and destroyItems and destroyItems:contains(addBackAction.item)) then
                table.insert(actionsToAddBack,addBackAction)
            end
        end
    end
    return actionsToAddBack
end

function PI2ABUtil.IsAllowed(playerObj)
    -- todo add sandbox setting
    -- if playerObj:hasTrait(CharacterTrait.DISORGANIZED) then return end
    -- b41: if playerObj:HasTrait("Disorganized") then
    --     return false
    -- end
    return true
end


function PI2ABUtil.GetItemIds(items)
    local ids = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local id = item:getID()
            if id then table.insert(ids, id) end
        end
    end
    return ids
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
            if item and not items:contains(item) then items:add(item) end
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
    if (isServer() or not debugOnly or PI2AB.Verbose) then
        print(txt)
    end
end

function PI2ABUtil.PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
    if queue then
        PI2ABUtil.Print("PI2AB: queue...", true)

        for i, action in ipairs(queue) do
            local jobType = action.Type or '???'
            if jobType == 'ISInventoryTransferAction' then
                local destContainer = action.destContainer
                local srcContainer = action.srcContainer
                if destContainer or srcContainer then
                    local item = action.item:getFullType()
                    jobType = "Transfer " .. tostring(item) .. " (" .. action.item:getID() .. ") from " ..
                                tostring(srcContainer:getType()) .. " to " .. tostring(destContainer:getType())
                    PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType, true)
                end
            elseif action.item then
                local item = action.item:getFullType() or '???'
                PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType .. " (item: " .. item .. ")", true)
            elseif action.object then
                PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType .. " (object id: " .. tostring(action.object) .. ")", true)
            else
                PI2ABUtil.Print(tostring(i) .. ") action: " .. jobType, true)
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

function PI2ABUtil.Delay(func, delay)
    delay = delay or 1;
    local ticks = 0;
    local canceled = false;

    local function onTick()

        if not canceled and ticks < delay then
            ticks = ticks + 1;
            return;
        end

        Events.OnTick.Remove(onTick);
        if not canceled then func(); end
    end

    Events.OnTick.Add(onTick);
    return function()
        canceled = true;
    end
end

function PI2ABUtil.Sleep(t)
    local ntime = getTimestampMs() + t/10
    repeat until getTimestampMs() > ntime
end

function PI2ABUtil.SplitString(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
