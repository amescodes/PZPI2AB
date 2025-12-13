PI2ABTransferArgs = {}

function PI2ABTransferArgs:new(logic,widget,completedAction, recipe, playerObj, container, containers, selectedItem,all)
    local o = {}
    setmetatable(o, self)
    o.logic = logic
    o.widget = widget
    o.completedAction = completedAction
    o.recipe = recipe
    o.playerObj = playerObj
    o.container = container
    o.containers = containers
    o.selectedItem = selectedItem
    o.all = all
    return o
end
