ISWorldMenuElements = ISWorldMenuElements or {};

ISWorldMenuElements_ContextDisassemble_transferOnCraftComplete = function(completedAction, scrapDef, playerObj, square)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local previousAction = completedAction
    
    -- local src = ArrayList.new()
    -- local srcTools = scrapDef and scrapDef.tools
    -- if srcTools then
    --     for i = 1, #srcTools do
    --         src:add(srcTools[i])
    --     end
    -- end
    -- local srcTools2 = scrapDef and scrapDef.tools2
    -- if srcTools2 then
    --     for i = 1, #srcTools2 do
    --         src:add(srcTools2[i])
    --     end
    -- end
    -- local srcItems = PI2ABUtil.GetActualItemsFromMoveablesSource(playerInv,src)

    local itemsToTransfer
    if completedAction.timestamp then
        local comparer = PI2ABComparer.get(completedAction.timestamp)
        if comparer then
            local allItems = playerInv:getItems()
            itemsToTransfer = comparer:compare(allItems,nil)
            -- target container
            local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
            PI2ABUtil.Print("target container capacity "..tostring(capacity), true)
            local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
            PI2ABUtil.Print("target container contents weight START "..tostring(runningBagWeight), true)
            -- backup / default container
            local defContainer = PI2ABUtil.GetDefaultContainer(square,playerInv)
            local bCapacity = defContainer and defContainer:getCapacity() or 0
            PI2ABUtil.Print("default container capacity "..tostring(bCapacity), true)
            local bRunningBagWeight = defContainer and defContainer:getContentsWeight() or 0
            PI2ABUtil.Print("default container contents weight START "..tostring(bRunningBagWeight), true)
            -- check new items and queue transfer actions
            for i = 0, itemsToTransfer:size() - 1 do
                repeat
                    local it = itemsToTransfer:get(i)
                    local itemWeight = it:getWeight()
                    local destinationContainer
                    local possibleNewWeight = PZMath.roundFromEdges(runningBagWeight + itemWeight)
                    if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                        PI2ABUtil.Print("target container possibleNewWeight: "..tostring(possibleNewWeight), true)
                        runningBagWeight = possibleNewWeight
                        destinationContainer = targetContainer
                    else
                        if not defContainer or defContainer == nil then
                            break --continue
                        end
                        destinationContainer = square
                    end

                    local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                    tAction:setAllowMissingItems(true)
                    if not tAction.ignoreAction then
                        previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, tAction)
                    end
                until true

                -- local it = itemsToTransfer:get(i)
                -- local itemWeight = it:getWeight()
                -- local destinationContainer
                -- local possibleNewWeight = PZMath.roundFromEdges(runningBagWeight + itemWeight)
                -- if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                --     PI2ABUtil.Print("target container possibleNewWeight: "..tostring(possibleNewWeight), true)
                --     runningBagWeight = possibleNewWeight
                --     destinationContainer = targetContainer
                -- else
                --     possibleNewWeight = PZMath.roundFromEdges(bRunningBagWeight + itemWeight)
                --     if defContainer and defContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= bCapacity then
                --         PI2ABUtil.Print("default container possibleNewWeight: "..tostring(possibleNewWeight), true)
                --         bRunningBagWeight = possibleNewWeight
                --         destinationContainer = defContainer
                --     else
                --         destinationContainer = playerInv
                --     end
                -- end

                -- local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                -- tAction:setAllowMissingItems(true)
                -- if not tAction.ignoreAction then
                --     previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, tAction)
                -- end
            end

            PI2ABComparer.remove(completedAction.timestamp)
        end
    end
end

ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete = function(completedAction, scrapDef, playerObj, square)
    local playerInv = playerObj:getInventory()
    local targetContainer = PI2AB.getTargetContainer(playerObj)

    local previousAction = completedAction
    local itemsToTransfer
    if completedAction.timestamp then
        local comparer = PI2ABComparer.get(completedAction.timestamp)
        if comparer then
            -- local allItems = playerInv:getItems()
            local allItems = square:getWorldObjects()
            itemsToTransfer = comparer:compare(allItems,nil)
            -- target container
            local capacity = targetContainer and targetContainer:getEffectiveCapacity(playerObj) or 0
            PI2ABUtil.Print("target container capacity "..tostring(capacity), true)
            local runningBagWeight = targetContainer and targetContainer:getContentsWeight() or 0
            PI2ABUtil.Print("target container contents weight START "..tostring(runningBagWeight), true)

            local defContainer = PI2ABUtil.GetDefaultContainer(nil,playerInv)
            -- check new items and queue transfer actions            
            for i = 0, itemsToTransfer:size() - 1 do
                repeat
                    local it = itemsToTransfer:get(i):getItem()
                    local itemWeight = it:getWeight()
                    local destinationContainer
                    local possibleNewWeight = PZMath.roundFromEdges(runningBagWeight + itemWeight)
                    if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                        PI2ABUtil.Print("target container possibleNewWeight: "..tostring(possibleNewWeight), true)
                        runningBagWeight = possibleNewWeight
                        destinationContainer = targetContainer
                    else
                        if not defContainer or defContainer == nil then
                            break --continue
                        end
                        destinationContainer = playerInv
                    end

                    local tAction = ISInventoryTransferAction:new(playerObj, it, it:getContainer(), destinationContainer, nil)
                    tAction:setAllowMissingItems(true)
                    if not tAction.ignoreAction then
                        previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, tAction)
                    end
                until true

                -- local it = itemsToTransfer:get(i)
                -- local itemWeight = it:getWeight()
                -- local destinationContainer
                -- local possibleNewWeight = PZMath.roundFromEdges(runningBagWeight + itemWeight)
                -- if targetContainer and targetContainer:hasRoomFor(playerObj, it) and possibleNewWeight <= capacity then
                --     PI2ABUtil.Print("target container possibleNewWeight: "..tostring(possibleNewWeight), true)
                --     runningBagWeight = possibleNewWeight
                --     destinationContainer = targetContainer
                -- else
                --     if defContainer ~= nil then
                --         destinationContainer = playerInv
                --     end
                -- end

                -- local tAction = ISInventoryTransferAction:new(playerObj, it, playerInv, destinationContainer, nil)
                -- tAction:setAllowMissingItems(true)
                -- if not tAction.ignoreAction then
                --     previousAction = PI2ABUtil.AddWhenToTransferAction(previousAction, tAction)
                -- end
            end

            PI2ABComparer.remove(completedAction.timestamp)
        end
    end
end

-- local function tableContains( _table, _item )
--     for _,v in ipairs(_table) do
--         if v==_item then return true end
--     end
--     return false;
-- end

-- --call after getAllObjects
-- local function getObjectsSquare( _data, _sq )
--     if _sq and not tableContains(_data.squares, _sq) then
--         table.insert( _data.squares, _sq);
--         for i=0, _sq:getObjects():size()-1 do
--             local obj = _sq:getObjects():get(i);
--             if not _data.contains[obj] then
--                 table.insert(_data.objects, obj);
--                 _data.contains[obj] = true
--             end
--         end
--     end
-- end

-- local function getAllObjects( _data )
--     local temp = _data.objects;
--     _data.objects = {};
--     _data.contains = {}
--     for _,obj in ipairs(temp) do
--         local sq = obj:getSquare();
--         getObjectsSquare( _data, sq )

--         if not _data.contains[obj] then
--             table.insert(_data.objects, obj);
--             _data.contains[obj] = true
--         end
--     end
--     return _data.objects;
-- end

local old_ISWorldMenuElements_ContextDisassemble = ISWorldMenuElements.ContextDisassemble
function ISWorldMenuElements.ContextDisassemble()
    local self = old_ISWorldMenuElements_ContextDisassemble()

    local old_disassemble = self.disassemble
    self.disassemble = function( _data, _v )
        old_disassemble( _data, _v )
        local player = _data.player
        local playerInv = player:getInventory()
        if _v and _v.moveProps and _v.square and _v.object then
            local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
            if queue then
                local action = PI2ABUtil.GetMovablesAction(queue)
                if action and action.moveProps then
                    local props = action.moveProps
                    local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition(action.moveProps.material)
                    local beforeItems
                    if props.customItem or scrapDef.addToInventory then
                        beforeItems = playerInv:getItems()
                        action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferOnCraftComplete, action, scrapDef, player)
                    else
                        -- items dumped to ground
                        -- local containers = ISInventoryPaneContextMenu.getContainers(player)
                        beforeItems = _v.square:getWorldObjects()
                        local beforeItems2 = _v.square:getWorldObjects()
                        action:setOnComplete(ISWorldMenuElements_ContextDisassemble_transferFromGroundOnCraftComplete, action, scrapDef, player,_v.square)
                    end

                    local timestamp = os.time()
                    action.timestamp = timestamp
                    PI2ABComparer.create(timestamp,beforeItems)
                end
            end
        end
    end

    return self;
end

