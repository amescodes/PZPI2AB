require "PI2ABUtil"

PI2ABComparer = {}
PI2ABComparer.Comparers = {}

function PI2ABComparer.get(time)
    return PI2ABComparer.Comparers[time]
end
function PI2ABComparer.create(time, items)
    local comparer = PI2ABComparer:new(time)
    comparer:setBefore(items)
    PI2ABComparer.Comparers[time] = comparer
    return comparer
end

function PI2ABComparer:setBefore(items)
    if not items then
        return
    end

    self.before = PI2ABUtil.ShallowClone(items)
end

function PI2ABComparer:compare(items, source)
    if not self.before or self.before:size() == 0 then
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
    if source and source:size() > 0 then
        for j = 0, source:size() - 1 do
            local srcItem = source:get(j)
            local foundSrcItem = result:remove(srcItem)
        end
    end

    return result
end

function PI2ABComparer:new(time)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.timestamp = time
    o.before = nil

    return o
end
