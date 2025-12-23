ISWorldMenuElements = ISWorldMenuElements or {};

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
            local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
            if queue then
                local action = PI2ABUtil.GetMovablesAction(queue)
                if action and action.moveProps then
                    local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
                    local beforeItems
                    if scrapDef.addToInventory then
                        beforeItems = playerInv:getItems()
                        -- action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferOnCraftComplete, action, player)
                        action:setOnComplete(PI2ABCore.PutInBagFromInventory, action, player)
                    else
                        -- items dumped to ground
                        beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(_v.square)
                        -- action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete, action, scrapDef, player, _v.square)
                        action:setOnComplete(PI2ABCore.PutInBagFromGround, action, player, _v.square)
                    end

                    local timestamp = os.time()
                    action.pi2ab_timestamp = timestamp
                    PI2ABComparer.create(timestamp, beforeItems)
                end
            end
        end
    end

    return self;
end

