ISWorldMenuElements = ISWorldMenuElements or {};

local pdata = nil
ISWorldMenuElements_ContextDisassemble_transferOnCraftComplete =
    function(completedAction, scrapDef, playerObj)
        PI2ABUtil.PutInBagFromInventory(playerObj, completedAction)
        -- local playerInv = playerObj:getInventory()
        -- local targetContainer = PI2AB.getTargetContainer(playerObj)
        -- local playerNum = playerObj:getPlayerNum()
        -- if pdata == nil then pdata = getPlayerData(playerNum) end
        -- if pdata then pdata.playerInventory:refreshBackpacks() end

        -- if completedAction.timestamp then
        --     local comparer = PI2ABComparer.get(completedAction.timestamp)
        --     if comparer then
        --         local allItems = playerInv:getItems()
        --         local itemsToTransfer = comparer:compare(allItems, nil)
        --         -- target container
        --         local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
        --         PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
        --         local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
        --         PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
        --         -- backup / default container
        --         local defContainer = PI2ABUtil.GetDefaultContainer(nil, playerInv)
        --         -- check new items and queue transfer actions
        --         for i = 0, itemsToTransfer:size() - 1 do
        --             local it = itemsToTransfer:get(i)
        --             local itemWeight = it:getWeight()
        --             local destinationContainer
        --             local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
        --             if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
        --                 PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
        --                 runningBagWeight = possibleNewWeight
        --                 destinationContainer = targetContainer
        --             else
        --                 if defContainer and defContainer ~= nil then
        --                     destinationContainer = nil
        --                 else
        --                     destinationContainer = ISInventoryPage.GetFloorContainer(playerNum)
        --                 end
        --             end
                    
        --             if destinationContainer then
        --                 local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
        --                 tAction:setAllowMissingItems(true)
        --                 if not tAction.ignoreAction then
        --                     ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
        --                 end
        --             end
        --         end
                
        --         PI2ABComparer.remove(completedAction.timestamp)
        --     end
        -- end
    end
    
ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete =
    function(completedAction, scrapDef, playerObj, square)
        PI2ABUtil.PutInBagFromGround(playerObj, completedAction, square)
        -- local playerInv = playerObj:getInventory()
        -- local targetContainer = PI2AB.getTargetContainer(playerObj)
        -- local playerNum = playerObj:getPlayerNum()
        -- if pdata == nil then pdata = getPlayerData(playerNum) end
        -- if pdata then pdata.lootInventory:refreshBackpacks() end
        
        -- if completedAction.timestamp then
        --     local comparer = PI2ABComparer.get(completedAction.timestamp)
        --     if comparer then
        --         local allItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
        --         local itemsToTransfer = comparer:compare(allItems, nil)
        --         -- target container
        --         local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
        --         PI2ABUtil.Print("target container capacity " .. tostring(capacity), true)
        --         local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
        --         PI2ABUtil.Print("target container contents weight START " .. tostring(runningBagWeight), true)
        --         -- backup / default container
        --         local defContainer = PI2ABUtil.GetDefaultContainer(nil, playerInv)
        --         -- check new items and queue transfer actions            
        --         for i = 0, itemsToTransfer:size() - 1 do
        --             local it = itemsToTransfer:get(i)
        --             local itemWeight = it:getWeight()
        --             local destinationContainer
        --             local possibleNewWeight = PI2ABUtil.Round(runningBagWeight + itemWeight)
        --             if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
        --                 PI2ABUtil.Print("target container possibleNewWeight: " .. tostring(possibleNewWeight), true)
        --                 runningBagWeight = possibleNewWeight
        --                 destinationContainer = targetContainer
        --             else
        --                 if defContainer and defContainer ~= nil then
        --                     destinationContainer = nil
        --                 else
        --                     destinationContainer = playerInv
        --                 end
        --             end
                    
        --             if destinationContainer then
        --                 local tAction = ISInventoryTransferAction:new(playerObj, it, ISInventoryPage.GetFloorContainer(playerNum), destinationContainer, nil)
        --                 tAction:setAllowMissingItems(true)
        --                 if not tAction.ignoreAction then
        --                     ISTimedActionQueue.getTimedActionQueue(playerObj):addToQueue(tAction)
        --                 end
        --             end
        --         end

        --         PI2ABComparer.remove(completedAction.timestamp)
        --     end
        -- end
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
            local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
            if queue then
                local action = PI2ABUtil.GetMovablesAction(queue)
                if action and action.moveProps then
                    local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
                    local beforeItems
                    if scrapDef.addToInventory then
                        beforeItems = playerInv:getItems()
                        action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferOnCraftComplete, action,
                            scrapDef, player)
                    else
                        -- items dumped to ground
                        beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(_v.square)
                        action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete,
                            action, scrapDef, player, _v.square)
                    end

                    local timestamp = os.time()
                    action.timestamp = timestamp
                    PI2ABComparer.create(timestamp, beforeItems)
                end
            end
        end
    end

    return self;
end

