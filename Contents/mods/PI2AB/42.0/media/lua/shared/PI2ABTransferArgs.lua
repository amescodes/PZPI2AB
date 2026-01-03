PI2ABTransferArgs = {}

function PI2ABTransferArgs:new(logic,widget, recipe, selectedItemContainer, containers, selectedItem, timestamp, sourceItemIds, all)
    local o = {}
    setmetatable(o, self)
    o.playerNum = 0
    o.logic = logic
    o.widget = widget
    o.recipe = recipe
    o.selectedItemContainer = selectedItemContainer
    o.containers = containers
    o.selectedItem = selectedItem
    o.timestamp = timestamp
    o.sourceItemIds = sourceItemIds
    o.all = all
    return o
end


PI2ABServerTransferArgs = {}

function PI2ABServerTransferArgs:new(targetContainerId,selectedItemContainer, itemIdsToTransfer, targetWeightTransferred, defWeightTransferred)
    local o = {}
    setmetatable(o, self)
    o.selectedItemContainer = selectedItemContainer
    o.targetContainerId = targetContainerId
    o.itemIdsToTransfer = itemIdsToTransfer
    o.targetWeightTransferred = targetWeightTransferred or 0
    o.defWeightTransferred = defWeightTransferred or 0
    return o
end
