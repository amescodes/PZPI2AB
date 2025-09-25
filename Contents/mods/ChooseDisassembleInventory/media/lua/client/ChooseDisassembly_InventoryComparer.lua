ChooseDisassemblyInventoryComparer = {};
ChooseDisassemblyInventoryComparer.Comparers = {}

function ChooseDisassemblyInventoryComparer.get(time)
    return ChooseDisassemblyInventoryComparer.Comparers[time]
end
function ChooseDisassemblyInventoryComparer.create(time, items)
    local comparer = ChooseDisassemblyInventoryComparer:new(time)
    comparer:setBefore(items)
    ChooseDisassemblyInventoryComparer.Comparers[time] = comparer
    return comparer
end

function ChooseDisassemblyInventoryComparer:setBefore(items)
    if not items then
        return
    end

    self.before = ShallowClone(items)
end

function ChooseDisassemblyInventoryComparer:compare(items, source)
    if not self.before or self.before:size() == 0 then
        return
    end
    if not items then
        return
    end

    -- set to after items to start
    local result = ShallowClone(items)
    for i = 0, self.before:size() - 1 do
        local item = self.before:get(i)
        if item then
            local foundBeforeItem = result:remove(item)
            local h = 0
        end
    end
    if source and source:size() > 0 then
        for j = 0, source:size() - 1 do
            local srcItem = source:get(j)
            local foundSrcItem = result:remove(srcItem)     
            local j = 0
        end
    end

    return result
end

function ChooseDisassemblyInventoryComparer:new(time)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.timestamp = time
    o.before = nil

    return o
end
