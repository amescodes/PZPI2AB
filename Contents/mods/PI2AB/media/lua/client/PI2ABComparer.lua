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

    -- if previousActionItems then
    --     local prevItems = PI2ABUtil.ShallowClone(items)
    --     for i = 0, previousActionItems:size() - 1 do
    --         local item = previousActionItems:get(i)
    --         if item then
    --             local foundBeforeItem = prevItems:remove(item)
    --         end
    --     end
    --     items = prevItems
    -- end

    comparer:setBefore(items)
    PI2ABComparer.Comparers[time] = comparer
    return comparer
end

function PI2ABComparer:setBefore(items)
    if not items then
        self.before = ArrayList.new()
    else
        self.before = PI2ABUtil.ShallowClone(items)
    end
end

function PI2ABComparer:compare(items, source)
    if not self.before then
        return
    end
    if not items then
        return
    end

    -- set to after items to start
    local result = PI2ABUtil.ShallowClone(items)

    for i = 0, self.before:size() - 1 do
        local item = self.before:get(i)
        if item then
            local foundBeforeItem = result:remove(item)
        end
    end

    if source then
        for j = 0, source:size() - 1 do
            local srcItem = source:get(j)
            if srcItem and result:contains(srcItem) then
                local foundSrcItem = result:remove(srcItem)
            end
        end
    end

    return result
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