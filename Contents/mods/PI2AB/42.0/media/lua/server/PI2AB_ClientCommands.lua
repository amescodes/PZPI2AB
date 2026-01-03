if isClient() then return end

local Commands = {}
Commands.PI2AB = {};

function Commands.PI2AB.transferOnCraftComplete(player, args)
    PI2ABCore.PutInBag(player,args.timestamp, args.selectedItemContainer, args.targetContainerId, args.itemIdsToTransfer)
end

function Commands.PI2AB.transferOnCraftComplete2(player, args)
    sendServerCommand(player, "PI2AB","transferOnCraftComplete", args)
end

local PI2ABCommands = {}
PI2ABCommands.OnClientCommand = function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
		local argStr = ''
		if args then
		    for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        end
		PI2ABUtil.Print('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[module][command](player, args)
	end
end

Events.OnClientCommand.Add(PI2ABCommands.OnClientCommand)
