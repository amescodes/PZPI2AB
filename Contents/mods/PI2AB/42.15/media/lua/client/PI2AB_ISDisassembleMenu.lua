ISWorldMenuElements = ISWorldMenuElements or {};

ISWorldMenuElements_ContextDisassemble_transferFromInventoryOnCraftComplete = function(player,timestamp)
    local comparer = PI2ABComparer.get(timestamp)
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

    PI2ABComparer.remove(timestamp)
end

ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete = function(player, square,timestamp)
    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end

    local playerNum = player:getPlayerNum()
    local pdata = getPlayerData(playerNum)
    if pdata then pdata.lootInventory:refreshBackpacks() end

    local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
    local itemIdsToTransfer = comparer:compare(allItems, nil)
	local targetContainer = PI2ABCore.GetTargetContainer(player)
    
    PI2ABCore.PutInBagFromGround(player, targetContainer, itemIdsToTransfer)
    
    local actionsToAddBack = comparer.actionsToAddBack
    if actionsToAddBack and #actionsToAddBack > 0 then
        for i = 1, #actionsToAddBack do
            ISTimedActionQueue.add(actionsToAddBack[i])
        end
    end
    
    PI2ABComparer.remove(timestamp)
end

local old_ISDisassembleMenu_disassemble = ISDisassembleMenu.disassemble
function ISDisassembleMenu.disassemble(player, _v)
    old_ISDisassembleMenu_disassemble(player, _v)

    if not PI2AB.Enabled or not PI2ABUtil.IsAllowed(player) then
        return
    end

    local playerInv = player:getInventory()
    if _v and _v.moveProps and _v.square and _v.object then
        local queueObj = ISTimedActionQueue.getTimedActionQueue(player)
        local queue = queueObj.queue
        if queue then
            -- if instanceof(_v.object,"IsoLightSwitch") and _v.object:hasLightBulb() then
            --     local lightAction,k = PI2ABUtil.GetMovablesAction(queue)
                
            --         local uniqueId = PI2ABUtil.GetMoveableUniqueId(_v.object)
            --         local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
            --         local beforeItems
            --         if scrapDef.addToInventory then
            --             beforeItems = playerInv:getItems()
            --             action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromInventoryOnCraftComplete, player, uniqueId)
            --         end
            -- end

            local action,i = PI2ABUtil.GetMovablesAction(queue)
            if action and action.moveProps and _v.object then
                local uniqueId = PI2ABUtil.GetMoveableUniqueId(_v.object,_v.square)
                local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
                local beforeItems
                if scrapDef.addToInventory then
                    beforeItems = playerInv:getItems()
                    action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromInventoryOnCraftComplete, player, uniqueId)
                else
                    -- items dumped to ground
                    beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(_v.square)
                    action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete, player, _v.square, uniqueId)
                end

                local actionsToAddBack = PI2ABUtil.GetAddBackActionsFromQueue(queueObj, nil, i)
                PI2ABComparer.create(uniqueId, actionsToAddBack, beforeItems)

                local dummyAction = PI2ABDummyAction:new(player, uniqueId)
                ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
    end
end

