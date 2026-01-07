ISWorldMenuElements = ISWorldMenuElements or {};

ISWorldMenuElements_ContextDisassemble_transferFromInventoryOnCraftComplete = function(player,timestamp)
    if isServer() then
        sendServerCommand(player, 'PI2AB', 'transferFromInventoryOnCraftComplete', { tiemstamp = timestamp })
        return
    end

    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end
    
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, nil)
    local targetContainer = PI2ABCore.GetTargetContainer(player)

    PI2ABCore.PutInBagFromInventory(player, targetContainer, timestamp, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end

    PI2ABComparer.remove(timestamp)
end

ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete = function(player, square,timestamp)
    if isServer() then
        sendServerCommand(player, 'PI2AB', 'transferFromGroundOnCraftComplete', { tiemstamp = timestamp, square = square })
        return
    end

    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end

    local playerNum = player:getPlayerNum()
    local pdata = getPlayerData(playerNum)
    if pdata then pdata.lootInventory:refreshBackpacks() end

    local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)
    
    PI2ABCore.PutInBagFromGround(player, targetContainer, timestamp, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end
    
    PI2ABComparer.remove(timestamp)
end

local old_ISWorldMenuElements_ContextDisassemble = ISWorldMenuElements.ContextDisassemble
function ISWorldMenuElements.ContextDisassemble()
    local self = old_ISWorldMenuElements_ContextDisassemble()

    local old_disassemble = self.disassemble
    self.disassemble = function(_data, _v)
        old_disassemble(_data, _v)
        
        local player = _data.player
        if not PI2ABUtil.IsAllowed(player) then
            return
        end

        local playerInv = player:getInventory()
        if _v and _v.moveProps and _v.square and _v.object then
            local queueObj = ISTimedActionQueue.getTimedActionQueue(player)
            local queue = queueObj.queue
            if queue then
                local action,i = PI2ABUtil.GetMovablesAction(queue)
                if action and action.moveProps then
                    local timestamp = os.time()
                    local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
                    local beforeItems
                    if scrapDef.addToInventory then
                        beforeItems = playerInv:getItems()
                        action:setOnComplete(PI2ABCore.PutInBagFromInventory, player, timestamp)
                    else
                        -- items dumped to ground
                        beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(_v.square)
                        action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete, player, _v.square, timestamp)
                    end

                    local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
                    PI2ABComparer.create(timestamp, actionsToAddBack, beforeItems)

                    local dummyAction = PI2ABDummyAction:new(player, timestamp)
                    ISTimedActionQueue.addAfter(action, dummyAction)
                end
            end
        end
    end

    return self;
end

