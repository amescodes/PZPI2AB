require "ChooseDisassemblyInventoryUtil"

if not ChooseDisassemblyInventory then
    ChooseDisassemblyInventory = {}
end

ChooseDisassemblyInventory.Enabled = true
ChooseDisassemblyInventory.Verbose = isDebugEnabled()

if not ChooseDisassemblyInventory.TargetContainer then
    ChooseDisassemblyInventory.TargetContainer = ""
end

function ChooseDisassemblyInventory.init()
    local player = getPlayer()
    if player == nil or player:getModData() == nil then
        return
    end

    if player:getModData().ChooseDisassemblyInventory == nil then
        -- create new mod data
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: creating new modData", true)
        player:getModData().ChooseDisassemblyInventory = {}
        ChooseDisassemblyInventory.TargetContainer = ""
    else
        -- load mod data
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: loading modData", true)
        for key, value in pairs(player:getModData().ChooseDisassemblyInventory) do
            ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:init: loading "..tostring(key).." = "..tostring(value), true)
            ChooseDisassemblyInventory[key] = value
        end
    end
end

Events.OnGameStart.Add(ChooseDisassemblyInventory.init)

function ChooseDisassemblyInventory:setTargetContainer(player,container)
    local containerId = container:getID()
    ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:setTargetContainer: container Id "..tostring(containerId), true)
    ChooseDisassemblyInventory.TargetContainer = containerId
    getSpecificPlayer(player):getModData()["ChooseDisassemblyInventory"]["TargetContainer"] = containerId
end

function ChooseDisassemblyInventory:isTargetContainer(container)
    local containerId = container:getID()
    ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory:isTargetContainer: container Id "..tostring(containerId), true)
    return ChooseDisassemblyInventory.TargetContainer and ChooseDisassemblyInventory.TargetContainer == containerId
end