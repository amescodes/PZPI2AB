require "PI2ABUtil"

PI2ABComparer = {}
PI2ABComparer.Comparers = {}

function PI2ABComparer.get(time)
    return PI2ABComparer.Comparers[time]
end

function PI2ABComparer.remove(time)
    PI2ABComparer.Comparers[time] = nil
end

function PI2ABComparer.create(time,actionsToAddBack, items, previousActionItems)
    local comparer = PI2ABComparer:new(time)

    local beforeIds = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local id = item:getID()
            if id then table.insert(beforeIds, id, item) end
        end
    end

    if previousActionItems then
        for i = 0, previousActionItems:size() - 1 do
            local prevItem = previousActionItems:get(i)
            if prevItem then
                local prevId = prevItem:getID()
                if beforeIds[prevId] then
                    beforeIds[prevId] = nil
                end
            end
        end
    end

    comparer.before = beforeIds
    comparer.actionsToAddBack = actionsToAddBack
    PI2ABComparer.Comparers[time] = comparer
    return comparer
end

function PI2ABComparer:compare(afterItems, sourceItemIds)
    if not afterItems then
        return
    end

    local transferIds = {}
    for i = 0, afterItems:size() - 1 do
        local item = afterItems:get(i)
        if item then
            local itemId = item:getID()
            if self.before[itemId] == nil then
                transferIds[itemId] = item
            end
        end
    end

    if sourceItemIds and #sourceItemIds > 0 then
        for j = 1, #sourceItemIds do
            local srcItemId = sourceItemIds[j]
            if transferIds[srcItemId] then
                transferIds[srcItemId] = nil
            end
        end
    end

    return transferIds
end

function PI2ABComparer:compareDebug(items, source)
    if not self.before or self.before:size() == 0 then
        return
    end
    if not items then
        return
    end

    -- set to after items to start
    local result = PI2ABUtil.ShallowClone(items)

    PI2ABUtil.Print("----ALL ITEMS---")
    PI2ABUtil.PrintArray(result)
    PI2ABUtil.Print("----END---")
    PI2ABUtil.Print("")

    if self.before and self.before:size() > 0 then
        PI2ABUtil.Print("----BEFORE---")
        for i = 0, self.before:size() - 1 do
            local item = self.before:get(i)
            if item then
                PI2ABUtil.Print(tostring(item))
                local foundBeforeItem = result:remove(item)
            end
        end
        PI2ABUtil.Print("----END---")
        PI2ABUtil.Print("")
    end

    if source and source:size() > 0 then
        PI2ABUtil.Print("----SOURCE---")
        for j = 0, source:size() - 1 do
            local srcItem = source:get(j)
            if srcItem then
                if result:contains(srcItem) then
                    PI2ABUtil.Print(tostring(srcItem))
                    local foundSrcItem = result:remove(srcItem)
                end
            end
        end
        PI2ABUtil.Print("----END---")
        PI2ABUtil.Print("")
    end

    PI2ABUtil.Print("----END RESULT---")
    PI2ABUtil.PrintArray(result)
    PI2ABUtil.Print("----END---")
    PI2ABUtil.Print("")

    return result
end

function PI2ABComparer:new(time)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pi2ab_timestamp = time
    o.before = nil

    o.actionsToAddBack = nil

    o.targetWeightTransferred = 0
    o.defWeightTransferred = 0

    return o
end

local function clearComparers()
    local player = getPlayer()
    local state = player:getActionStateName()
    if player:isPerformingAnAction() or state ~= "idle" or #PI2ABComparer.Comparers == 0 then
        return
    end

    PI2ABUtil.Print("Leftover comparers:",true)
    PI2ABUtil.PrintTable(PI2ABComparer.Comparers)
    PI2ABUtil.Print("--------",true)

    PI2ABComparer.Comparers = {}
end

Events.EveryTenMinutes.Add(clearComparers)