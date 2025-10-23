require "ChooseDisassemblyInventoryUtil"

if not ChooseDisassemblyInventory then
    ChooseDisassemblyInventory = {}
end


ChooseDisassemblyInventory.Verbose = isDebugEnabled()
ChooseDisassemblyInventory.Enabled = true
ChooseDisassemblyInventory.DefaultDestinationContainer = 1
ChooseDisassemblyInventory.WhenToTransferItems = 1
ChooseDisassemblyInventory.TargetContainer = ""

function ChooseDisassemblyInventory.init()
    local player = getPlayer()
    if player == nil or player:getModData() == nil then
        return
    end

    if player:getModData().ChooseDisassemblyInventory == nil then
        -- create new mod data
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory:init: creating new modData", true)
        player:getModData().ChooseDisassemblyInventory = {}
        ChooseDisassemblyInventory.TargetContainer = ""
    else
        -- load mod data
        ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory:init: loading modData", true)
        for key, value in pairs(player:getModData().ChooseDisassemblyInventory) do
            ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory:init: loading "..tostring(key).." = "..tostring(value), true)
            ChooseDisassemblyInventory[key] = value
        end
    end
end

-- Events.OnGameStart.Add(ChooseDisassemblyInventory.init)

function ChooseDisassemblyInventory:setTargetContainer(player,container)
    local containerId = container:getID()
    ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory:setTargetContainer: container Id "..tostring(containerId), true)
    ChooseDisassemblyInventory.TargetContainer = containerId
    getSpecificPlayer(player):getModData()["ChooseDisassemblyInventory"]["TargetContainer"] = containerId
end

function ChooseDisassemblyInventory:isTargetContainer(container)
    local containerId = container:getID()
    ChooseDisassemblyInventoryUtil.Print("ChooseDisassemblyInventory:isTargetContainer: container Id "..tostring(containerId), true)
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

    for _, v in ipairs(items) do
        local testItem = v
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1]
        end
        if instanceof(testItem, "InventoryContainer") then
            -- check for keys and moveables
            if testItem:getFullType() == "Base.KeyRing" then return end

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
