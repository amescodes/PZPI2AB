PI2ABResult = {}

function PI2ABResult:new(previousAction, completedAction, itemsToTransfer, targetWeightTransferred, defWeightTransferred)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.previousAction = previousAction
    o.completedAction = completedAction
    o.itemsToTransfer = itemsToTransfer
    o.targetWeightTransferred = targetWeightTransferred or 0.0
    o.defWeightTransferred = defWeightTransferred or 0.0

    return o
end
