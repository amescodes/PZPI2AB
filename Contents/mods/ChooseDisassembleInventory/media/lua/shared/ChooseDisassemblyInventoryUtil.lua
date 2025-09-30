if not ChooseDisassemblyInventoryUtil then
    ChooseDisassemblyInventoryUtil = {}
end

function ChooseDisassemblyInventoryUtil.Print(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if not debugOnly then
        print(txt)
    end
end

function ChooseDisassemblyInventoryUtil.PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
    if queue then
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory: queue...", true)
        for i, action in ipairs(queue) do
            local jobType = action.jobType
            if not jobType then
                jobType = "???"
                local item = action.item:getFullType()
                ChooseDisassemblyInventoryUtil.Print("unknown job...item: "..item, true)
            end
            ChooseDisassemblyInventoryUtil.Print(tostring(i).. ") action: "..jobType, true)
        end
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory: queue END ", true)
    end
end

function ChooseDisassemblyInventoryUtil.PrintArray(array)
    if array then
        for i = 0, array:size() - 1 do 
            local s = array:get(i)
            ChooseDisassemblyInventoryUtil.Print(tostring(s), true)
        end
    end
end

function ChooseDisassemblyInventoryUtil.ShallowClone(array)
    local result = ArrayList.new()
    for i = 0, array:size() - 1 do
        result:add(array:get(i))
    end
    return result
end