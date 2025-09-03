require "ChooseDisassemblyInventoryUtil"

if not ChooseDisassemblyInventory then
    ChooseDisassemblyInventory = {}
end

ChooseDisassemblyInventory.Enabled = true
ChooseDisassemblyInventory.Verbose = isDebugEnabled()

if not ChooseDisassemblyInventory.Destination then
    ChooseDisassemblyInventory.Destination = ""
end

function ChooseDisassemblyInventory:init(player)
    if player == nil or player:getModData() == nil then
        return
    end

    if player:getModData().ChooseDisassemblyInventory == nil then
        -- create new mod data
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: creating new modData", true)
        player:getModData().ChooseDisassemblyInventory = {}
        ChooseDisassemblyInventory.Destination = ""
    else
        -- load mod data
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: loading modData", true)
        for key, value in pairs(player:getModData().ChooseDisassemblyInventory) do
            ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: loading "..tostring(key).." = "..tostring(value), true)
            ChooseDisassemblyInventory[key] = value
        end
    end
end