local PI2ABCommands = {}

local Commands = {}

Commands.PI2AB = {};

function Commands.PI2AB.transferFromGroundOnCraftComplete(player, args)
    PI2ABCore.PutInBagFromGround(args.action, player, args.square)
end

-- PI2ABCommands.OnClientCommand = function(module, command, player, args)
PI2ABCommands.OnServerCommand = function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
		local argStr = ''
		if args then
		    for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        end
		noise('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[module][command](player, args)
	end
end

-- Events.OnClientCommand.Add(PI2ABCommands.OnClientCommand)
Events.OnServerCommand.Add(PI2ABCommands.OnServerCommand)
