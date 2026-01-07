local PI2ABCommands = {}

local Commands = {}

Commands.PI2AB = {};

-- function Commands.PI2AB.transferOnCraftComplete(player, args)
-- 	local targetContainer = PI2ABCore.GetTargetContainer(player)
--     local comparer = PI2ABComparer.get(args.timestamp)
--     local allItems = player:getInventory():getItems()
--     local itemIdsToTransfer = comparer:compare(allItems, args.sourceItemIds)
--     PI2ABCore.PutInBag(player,args.timestamp, comparer.selectedItemContainer, targetContainer, itemIdsToTransfer,args.targetWeightTransferred, args.defWeightTransferred)
-- end

-- function Commands.PI2AB.transferFromGroundOnCraftComplete(player, args)
--     PI2ABCore.PutInBagFromGround(args.action, player, args.square)
-- end


function Commands.transferFromInventoryOnCraftComplete(player,args)
    if isServer() then
        return
    end
	local timestamp  = args.timestamp

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

function Commands.transferFromGroundOnCraftComplete(player, args)
    -- sendServerCommand(player, 'PI2AB', 'transferFromGroundOnCraftComplete', { action = action, square = square })
	local timestamp  = args.timestamp
	local square = args.square
	
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

PI2ABCommands.OnServerCommand = function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
		local argStr = ''
		if args then
		    for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        end
		PI2ABUtil.Print('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[module][command](player, args)
	end
end

Events.OnServerCommand.Add(PI2ABCommands.OnServerCommand)
