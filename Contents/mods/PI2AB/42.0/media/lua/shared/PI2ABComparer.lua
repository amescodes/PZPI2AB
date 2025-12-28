require "PI2ABUtil"

PI2ABComparer = {}
PI2ABComparer.Comparers = {}

function PI2ABComparer.get(time)
    return PI2ABComparer.Comparers[time]
end

function PI2ABComparer.remove(time)
    PI2ABComparer.Comparers[time] = nil
end

function PI2ABComparer.create(time, items, previousActionItems, targetWeightTransferred, defWeightTransferred)
    local comparer = PI2ABComparer:new(time, targetWeightTransferred, defWeightTransferred)

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
    PI2ABComparer.Comparers[time] = comparer
    return comparer
end

function PI2ABComparer:compare(afterItems, source)
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

    if source then
        for j = 0, source:size() - 1 do
            local srcItem = source:get(j)
            if srcItem then
                local srcItemId = srcItem:getID()
                if transferIds[srcItemId] then
                    transferIds[srcItemId] = nil
                end
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

function PI2ABComparer:new(time,targetWeightTransferred,defWeightTransferred)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pi2ab_timestamp = time
    o.before = nil

    o.targetWeightTransferred = targetWeightTransferred or 0
    o.defWeightTransferred = defWeightTransferred or 0

    return o
end
