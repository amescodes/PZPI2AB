if not CFarming_Interact then CFarming_Interact = {} end


local transferFromGroundOnCraftComplete = function(player, square,uniqueId)
    local comparer = PI2ABComparer.get(uniqueId)
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
    
    PI2ABComparer.remove(uniqueId)
end


local old_CFarming_Interact_onContextKey = CFarming_Interact.onContextKey
CFarming_Interact.onContextKey = function(player, timePressedContext)
    old_CFarming_Interact_onContextKey(player, timePressedContext)
    
	if player:getVehicle() then return end
	if not player:isAiming() then return end
	if player:hasTimedActions() then return end
	local dir = player:getDir()
	local square = player:getSquare():getAdjacentSquare(dir)
	if not square:getCanSee(player:getPlayerNum()) then return end
	if square:getMovingObjects():size() > 0 then return end
    if not ISFarmingMenu.walkToPlant(player, square) then return end
	local item = player:getPrimaryHandItem()

	local plant = CFarmingSystem.instance:getLuaObjectOnSquare(square)
    local canHarvest = plant and plant:canHarvest()
    local plow = plant and plant.state == "plow"

    -- interactions that don't need an item should go first
    -- if there's a harvestable plant in the square we harvest it
    if canHarvest then

        return
    end
	-- interactions that need an item should be below this
	if not item or item:isBroken() then return end

	local chopTree = item:hasTag(ItemTag.CHOP_TREE)
    local digPlow = item:hasTag(ItemTag.DIG_PLOW)
    local hasCuttingTool = item:hasTag(ItemTag.CUT_PLANT)
    local pickaxe = item:hasTag(ItemTag.PICK_AXE)
    local stoneMaul = item:hasTag(ItemTag.STONE_MAUL)
    local sledge = item:hasTag(ItemTag.SLEDGEHAMMER)
    local clubHammer = item:hasTag(ItemTag.CLUB_HAMMER)
    local scythe = item:hasTag(ItemTag.SCYTHE)

    -- if you have an axe and there's a tree you chop it
	if chopTree and square:HasTree() then

        return
	end
    -- if you have an cutting tool and there's a bush you remove it it
    local rmc = ISRemovePlantCursor:new(player, "bush")
	if hasCuttingTool and rmc:getRemovableObject(square) then

        return
	end
    if pickaxe and square:getStump() then

        return
    end
-- TODO: Doesn't work anymore, fix
    if (pickaxe or stoneMaul or sledge or clubHammer) and square:getOre() then

        return
    end

	-- if you have a tool to dig a furrow and you can dig one you dig one
	if digPlow and ISFarmingMenu.canDigHereSquare(square) then
		
        return
	end

    -- if you have the tool unused furrows are removed
    -- dead plants are now restored to furrows, earlier
    if plow and digPlow then

        return
    end
    -- scythe the grass
    if scythe  and square then
        local queueObj = ISTimedActionQueue.getTimedActionQueue(player)
        local queue = queueObj.queue
        if queue then
            local action,i = PI2ABUtil.GetScythingAction(queue)
            if action then
                local uniqueId = PI2ABUtil.GetMoveableUniqueId(item,square) or nil       
                local beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
                action:setOnComplete(transferFromGroundOnCraftComplete, player, square, uniqueId)
                PI2ABComparer.create(uniqueId, nil, beforeItems)

                local dummyAction = PI2ABDummyAction:new(player, uniqueId)
                ISTimedActionQueue.addAfter(action, dummyAction)
            end
        end
        return
    end
end