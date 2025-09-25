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

function ChooseDisassemblyInventory:getTargetContainer(playerObj)
    local playerInv = playerObj:getInventory()
    local targetContainer
    if ChooseDisassemblyInventory.TargetContainer then
        local item = playerInv:getItemById(ChooseDisassemblyInventory.TargetContainer)
        if item then
            targetContainer = item:getItemContainer()
        end
    end
    
    return targetContainer
end

local function makeTargetContainer(item, player)
    if item then
        ChooseDisassemblyInventory:setTargetContainer(player,item)
    end
end

local function ChooseDisassemblyInventoryContextMenuEntry(player, context, items)
    if not ChooseDisassemblyInventory.Enabled then
        return
    end

    -- items = ISInventoryPane.getActualItems(items)
    for _, v in ipairs(items) do
        local testItem = v
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
        -- todo check not keys!
        if instanceof(testItem, "InventoryContainer") then
            local targetContainerOption = context:insertOptionAfter(getText("IGUI_CraftUI_Favorite"), getText("IGUI_ChooseDisassemblyInventory_TargetContainer"), testItem, makeTargetContainer, player)
            targetContainerOption.tooltip = getText("IGUI_ChooseDisassemblyInventory_TargetContainer_tooltip")
            local texture = getTexture("media/ui/RadioButtonCircle.png")
            local alreadyTarget = ChooseDisassemblyInventory:isTargetContainer(testItem)
            if alreadyTarget then
                targetContainerOption.notAvailable = true
                targetContainerOption.tooltip = ''
                texture = getTexture("media/ui/RadioButtonIndicator.png")
            end
            targetContainerOption.iconTexture = texture
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ChooseDisassemblyInventoryContextMenuEntry)
