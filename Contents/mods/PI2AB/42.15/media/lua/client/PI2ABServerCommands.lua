local PI2ABCommands = {}
local Commands = {}

Commands.PI2AB = {}

Commands.PI2AB.transferFromInventoryOnCraftComplete = function(args)
    local player = getSpecificPlayer(args.playerNum)
    if not player or not PI2AB.Enabled or not PI2ABUtil.IsAllowed(player) then
        return
    end

    local timestamp  = args.timestamp

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

Commands.PI2AB.transferFromGroundOnCraftComplete = function(args)
    local playerNum = args.playerNum
    local player = getSpecificPlayer(playerNum)
    if not player or not PI2AB.Enabled or not PI2ABUtil.IsAllowed(player) then
        return
    end    
    
	local timestamp  = args.timestamp
    local square = getCell():getGridSquare(args.x, args.y, args.z);
	
    local comparer = PI2ABComparer.get(timestamp)
    if not comparer then return end
    
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
    PI2ABUtil.PrintQueue(player)
    PI2ABComparer.remove(timestamp)
end

PI2ABCommands.OnServerCommand = function(module, command, args)
    if Commands[module] and Commands[module][command] then
        local argStr = ''
        -- Can be nil if sending an empty table
        if args then
            for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        end
        PI2ABUtil.Print('PI2AB: received command '..module..' '..command..' argStr: '..argStr)
        Commands[module][command](args)
    end
end

Events.OnServerCommand.Add(PI2ABCommands.OnServerCommand)
