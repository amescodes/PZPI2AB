PI2ABTransferArgs = {}

function PI2ABTransferArgs:new(playerNum,logic, widget, recipe, selectedItemContainer, containers, selectedItem, timestamp, sourceItemIds, all)
    local o = {}
    setmetatable(o, self)
    o.playerNum = playerNum or 0
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