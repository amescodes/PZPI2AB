function ChooseDisassemblyInventoryPrint(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if not debugOnly or ChooseDisassemblyInventory.Verbose then
        print(txt)
    end
end

function ChooseDisassemblyInventory_PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
    if queue then
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory: queue...", true)
        for i, action in ipairs(queue) do
            local jobType = action.jobType
            if not jobType then
                jobType = "???"
                local item = action.item:getFullType()
                ChooseDisassemblyInventoryPrint("unknown job...item: "..item, true)
            end
            ChooseDisassemblyInventoryPrint(tostring(i).. ") action: "..jobType, true)
        end
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory: queue END ", true)
    end
end
