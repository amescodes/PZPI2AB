local function transferOnScytheGrassComplete(player, square,uniqueId)
    if isServer() then
        return
    end

    local comparer = PI2ABComparer.get(uniqueId)
    if not comparer then return end
    
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBagFromInventory(player, targetContainer, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end

    PI2ABComparer.remove(uniqueId)
end

local old_ISScytheGrassCursor_create = ISScytheGrassCursor.create
function ISScytheGrassCursor:create(x, y, z, north, sprite)
    old_ISScytheGrassCursor_create(self, x, y, z, north, sprite)

    local playerObj = self.character
    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(playerObj) then return end

    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    if queue then
        local action,i = PI2ABUtil.GetScythingAction(queue)
        if action then
            local square = action.sq
            local uniqueId = PI2ABUtil.GetSqUniqueId("scythe",square)
            action:setOnComplete(transferOnScytheGrassComplete, playerObj, square,uniqueId)

            local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
            PI2ABComparer.create(uniqueId, actionsToAddBack, playerObj:getInventory():getItems())

            local dummyAction = PI2ABDummyAction:new(playerObj, uniqueId)
            ISTimedActionQueue.addAfter(action, dummyAction)
        end
    end
end
