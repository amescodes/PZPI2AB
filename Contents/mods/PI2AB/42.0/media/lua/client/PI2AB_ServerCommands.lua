local PI2ABCommands = {}

local Commands = {}

Commands.PI2AB = {};

function Commands.PI2AB.transferOnCraftComplete(player, args)
	local targetContainer = PI2ABCore.GetTargetContainer(player)
    local comparer = PI2ABComparer.get(args.timestamp)
    local allItems = player:getInventory():getItems()
    local itemIdsToTransfer = comparer:compare(allItems, args.sourceItemIds)
    PI2ABCore.PutInBag(player,args.timestamp, comparer.selectedItemContainer, targetContainer, itemIdsToTransfer,args.targetWeightTransferred, args.defWeightTransferred)
end

function Commands.PI2AB.transferFromGroundOnCraftComplete(player, args)
    PI2ABCore.PutInBagFromGround(args.action, player, args.square)
end

-- PI2ABCommands.OnClientCommand = function(module, command, player, args)
PI2ABCommands.OnServerCommand = function(module, command, player, args)
	PI2ABUtil.Print("PI2ABCommands.OnServerCommand: "..module.." "..command.." "..tostring(player), true)
	if Commands[module] and Commands[module][command] then
		local argStr = ''
		if args then
		    for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        end
		PI2ABUtil.Print('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[module][command](player, args)
	end
end

-- Events.OnClientCommand.Add(PI2ABCommands.OnClientCommand)
Events.OnServerCommand.Add(PI2ABCommands.OnServerCommand)
