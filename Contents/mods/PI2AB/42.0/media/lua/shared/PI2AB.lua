require "PI2ABUtil"

if not PI2AB then
    PI2AB = {}
end

PI2AB.Verbose = isDebugEnabled()
PI2AB.Enabled = true
PI2AB.DefaultDestinationContainer = 1
PI2AB.WhenToTransferItems = 1
PI2AB.TargetContainer = ""

function PI2AB.init()
    local player = getPlayer()
    local modData = player:getModData()
    if player == nil or modData == nil then
        return
    end

    if modData.PI2AB == nil then
        -- create new mod data
        PI2ABUtil.Print("PI2AB.init: creating new modData", true)
        modData.PI2AB = {}
        modData.TargetContainer = ""
    else
        -- load mod data
        PI2ABUtil.Print("PI2AB:init: loading modData", true)
        for key, value in pairs(modData.PI2AB) do
            PI2ABUtil.Print("PI2AB:init: loading "..tostring(key).." = "..tostring(value), true)
            PI2AB[key] = value
        end
    end
end

function PI2AB.getTargetContainer(playerObj)
    local playerInv = playerObj:getInventory()
    if PI2AB.TargetContainer and PI2AB.TargetContainer ~= "" then
        local item = playerInv:getItemWithID(PI2AB.TargetContainer)
        if item and item:isEquipped() then
            return item:getItemContainer()
        end
    end
    return nil
end

local function setTargetContainer(playerNum,container)
    local containerId = container:getID()
    PI2ABUtil.Print("setTargetContainer: container Id "..tostring(containerId), true)
    PI2AB.TargetContainer = containerId
    local player = getSpecificPlayer(playerNum)
    if player then
        player:getModData().PI2AB.TargetContainer = containerId
    end
end

local function makeTargetContainer(item, player)
    if item then
        setTargetContainer(player,item)
    end
end

local function isTargetContainer(container)
    local containerId = container:getID()
    PI2ABUtil.Print("PI2AB.isTargetContainer: container Id "..tostring(containerId), true)
    return PI2AB.TargetContainer and PI2AB.TargetContainer == containerId
end

local function setTargetContextMenuEntry(player, context, items)
    if not PI2AB.Enabled then
        return
    end

    for _, v in ipairs(items) do
        local testItem = v
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1]
        end
        if instanceof(testItem, "InventoryContainer") and testItem:isEquipped() then
            if testItem:getFullType() == "Base.KeyRing" then return end

            local targetContainerOption = context:insertOptionAfter(getText("IGUI_CraftUI_Favorite"), getText("IGUI_PI2AB_TargetContainer"), testItem, makeTargetContainer, player)
            targetContainerOption.tooltip = getText("IGUI_PI2AB_TargetContainer_tooltip")
            local texture = getTexture("media/ui/RadioButtonCircle.png")
            local alreadyTarget = isTargetContainer(testItem)
            if alreadyTarget then
                targetContainerOption.tooltip = getText("IGUI_PI2AB_IsTargetContainer_tooltip")
                texture = getTexture("media/ui/RadioButtonIndicator.png")
            end
            targetContainerOption.iconTexture = texture
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(setTargetContextMenuEntry)

local function resetTargetContainer(target,playerNum)
    if playerNum then
        PI2AB.TargetContainer = ""
        local player = getSpecificPlayer(playerNum)
        if player then
            player:getModData().PI2AB.TargetContainer = ""
        end
    end
end

local function resetTargetContextMenuEntry(player, context,isLoot)
    if not PI2AB.Enabled then
        return
    end
    if not isLoot then
        local resetTargetOption = context:addOption( getText("IGUI_PI2AB_ResetTarget"), nil, resetTargetContainer, player)
        resetTargetOption.tooltip = getText("IGUI_PI2AB_ResetTarget_tooltip")
    end
end

LuaEventManager.AddEvent("OnFillInventoryContextMenuNoItems")
Events.OnFillInventoryContextMenuNoItems.Add(resetTargetContextMenuEntry)
