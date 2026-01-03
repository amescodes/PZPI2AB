require "TimedActions/ISInventoryTransferAction"

PI2ABInventoryTransferAction = ISInventoryTransferAction:derive("PI2ABInventoryTransferAction");

function PI2ABInventoryTransferAction:isValid()
	local result = ISInventoryTransferAction.isValid(self)

	return result
-- 	if not self.item then
-- 		return false;
--     end
--     -- fix for players being able to replace items into containers they shouldnt
--     if not ISInventoryPaneContextMenu.getContainers(self.character):contains(self.destContainer) then
--         return false;
--     end
--     -- fix for players being able to add ingredients to evolved recipes after walking away from the container they are in
--     if not ISInventoryPaneContextMenu.getContainers(self.character):contains(self.srcContainer) then
--         return false;
--     end

--     -- fix for items that were consumed in crafting still being put back into their container
-- 	if self.item:getIsCraftingConsumed() then
-- 		return false;
--     end
-- 	self.dontAdd = false;
-- 	if not self.destContainer or not self.srcContainer then return false; end
	
-- 	-- Limit items per container in MP
-- 	if isClient() then
-- 		if not self.started and not isItemTransactionConsistent(self.item, self.srcContainer, self.destContainer, nil, self.character) then
-- 			return false
-- 		end
-- 		local limit = getServerOptions():getInteger("ItemNumbersLimitPerContainer");
-- 		if limit > 0 and (not instanceof(self.destContainer:getParent(), "IsoGameCharacter")) then
-- 			--allow dropping full bags on an empty square or put full container in an empty container
-- 			if not self.destContainer:getItems():isEmpty() then
-- 				local destRoot = luautils.findRootInventory(self.destContainer);
-- 				local srcRoot = luautils.findRootInventory(self.srcContainer);
-- 				--total count remains the same if the same root container
-- 				if srcRoot ~= destRoot then
-- 					local transferItemsNum = 1;
-- 					if self.item:getCategory() == "Container" then
-- 						transferItemsNum = luautils.countItemsRecursive({self.item:getInventory()}, 1);
-- 					end;
-- 					--count items from the root container
-- 					local destContainerItemsNum = luautils.countItemsRecursive({destRoot}, 0);
-- 					--if destination is an item then add 1
-- 					if destRoot:getContainingItem() then destContainerItemsNum = destContainerItemsNum + 1; end;
-- 					--total items must not exceed the server limit
-- 					if destContainerItemsNum + transferItemsNum > limit then
-- 						return false;
-- 					end;
-- 				end;
-- 			end;
-- 		end;
-- 		return true;
-- 	end;
	
-- 	if self.allowMissingItems and not self.srcContainer:contains(self.item) then -- if the item is destroyed before, for example when crafting something, we want to transfer the items left back to their original position, but some might be destroyed by the recipe (like molotov, the gas can will be returned, but the ripped sheet is destroyed)
-- --		self:stop();
-- 		self.dontAdd = true;
-- 		return true;
-- 	end
-- 	if (not self.destContainer:isExistYet()) or (not self.srcContainer:isExistYet()) then
-- 		return false
-- 	end

-- 	local parent = self.srcContainer:getParent()
-- 	-- Duplication exploit: drag items from a corpse to another container while pickup up the corpse.
-- 	-- ItemContainer:isExistYet() would detect this if SystemDisabler.doWorldSyncEnable was true.
-- 	if instanceof(parent, "IsoDeadBody") and parent:getStaticMovingObjectIndex() == -1 then
-- 		return false
-- 	end

-- 	-- Don't fail if the item was transferred by a previous action.
-- 	if self:isAlreadyTransferred(self.item) then
-- 		return true
-- 	end

--     if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
--         return false;
-- 	end
-- 	if not self.srcContainer:contains(self.item) then
-- 		return false;
--     end
--     if self.srcContainer == self.destContainer then return false; end

--     if self.destContainer:getType()=="floor" then
-- 		--[[
--         if instanceof(self.item, "Moveable") and self.item:getSpriteGrid()==nil then
--             if not self.item:CanBeDroppedOnFloor() then
--                 return false;
--             end
--         end
--         ]]--
--         if self:getNotFullFloorSquare(self.item) == nil then
--             return false;
--         end
--     elseif not self.destContainer:hasRoomFor(self.character, self.item) then
--         return false;
--     end

--     if not self.srcContainer:isRemoveItemAllowed(self.item) then
--         return false;
--     end
--     if not self.destContainer:isItemAllowed(self.item) then
--         return false;
--     end
--     if self.item:getContainer() == self.srcContainer and not self.destContainer:isInside(self.item) then
--         return true;
--     end
--     if isClient() and self.srcContainer:getSourceGrid() and SafeHouse.isSafeHouse(self.srcContainer:getSourceGrid(), self.character:getUsername(), true) then
--         return false;
-- 	end
--     return false;
end

function PI2ABInventoryTransferAction:update()
	ISInventoryTransferAction.update(self)

	-- if isClient() then
	-- 	if isItemTransactionDone(self.transactionId) then
	-- 		self:forceComplete();
	-- 	elseif isItemTransactionRejected(self.transactionId) then
	-- 		self:forceStop();
	-- 	end

    --     if self.maxTime == -1 then
    --         local duration = getItemTransactionDuration(self.transactionId)
    --         if duration > 0 then
    --             self.maxTime = duration
    --             self.action:setTime(self.maxTime)
    --         end
    --     end
	-- end
end

function PI2ABInventoryTransferAction:start()
	ISInventoryTransferAction.start(self)

	if isClient() then
		self.action:setWaitForFinished(false)
	end

-- 	if self:isAlreadyTransferred(self.item) then
-- 		self.selectedContainer = nil
-- 		self.action:setTime(0)
-- 		return
-- 	end

-- 	if self.dontAdd then
-- 		self.selectedContainer = nil
-- 		self.action:setTime(0)
-- 		return
-- 	end

-- 	if self.character:isPlayerMoving() then
-- 		self.maxTime = self.maxTime * 1.5
-- 		self.action:setTime(self.maxTime)
-- 	end

--     -- stop microwave working when putting new stuff in it
--     if self.destContainer and self.destContainer:getType() == "microwave" and self.destContainer:getParent() and self.destContainer:getParent():Activated() then
--         self.destContainer:getParent():setActivated(false);
--     end
--     if self.srcContainer and self.srcContainer:getType() == "microwave" and self.srcContainer:getParent() and self.srcContainer:getParent():Activated() then
--         self.srcContainer:getParent():setActivated(false);
--     end
-- 	self:playSourceContainerOpenSound()
-- 	self:playDestContainerOpenSound()
--     if ISInventoryTransferAction.putSoundContainer ~= self.destContainer then
--         ISInventoryTransferAction.putSoundTime = 0
--     end
-- --    if self.destContainer:getPutSound() then
--     if self.item and self.item:getType() == "Animal" then
--         -- Hack: The put_down breed sound will be played by IsoGridSquare.AddWorldInventoryItem().
--     elseif not ISInventoryTransferAction.putSound or not self.character:getEmitter():isPlaying(ISInventoryTransferAction.putSound) then
--         -- Players with the Deaf trait don't play sounds.  In multiplayer, we mustn't send multiple sounds to other clients.
--         local soundName = self:getTransferStartSoundName()
--         if soundName then
--             ISInventoryTransferAction.putSoundContainer = self.destContainer
--             if ISInventoryTransferAction.putSoundTime + ISInventoryTransferAction.putSoundDelay < getTimestamp() then
--                 ISInventoryTransferAction.putSoundTime = getTimestamp()
--                 ISInventoryTransferAction.putSound = self.character:getEmitter():playSound(soundName)
--             end
--         end
--     end
--     self.loopSound = self.character:getEmitter():playSound("RummageInInventory")
--     self.loopSoundNoTrigger = true
-- --    end

-- 	if isClient() then
-- 		self.action:setWaitForFinished(true)
-- 	end

-- 	self:startActionAnim()
-- 	self.transactionId = createItemTransaction(self.character, self.item, self.srcContainer, self.destContainer)
-- 	self.started = true
end

function PI2ABInventoryTransferAction:stop()
	ISInventoryTransferAction.stop(self)

	-- self:playSourceContainerCloseSound()
	-- self:playDestContainerCloseSound()
	-- self:stopLoopingSound()
	-- self.item:setJobDelta(0.0);
	-- if self.action then
	-- 	self.action:setLoopedAction(false);
	-- end
	-- --if self.transactions then
	-- --	for _,transaction in ipairs(self.transactions) do
	-- --		removeItemTransaction(transaction[1], transaction[2], transaction[3])
	-- --	end
	-- --end
	-- removeItemTransaction(self.transactionId, true)
	-- ISBaseTimedAction.stop(self);
	-- self.started = false
end

function PI2ABInventoryTransferAction:forceComplete()
	ISInventoryTransferAction.forceComplete(self)
	-- if not isClient() then
	-- 	return;
	-- end
	-- self.maxTime = 0.0
	-- self.action:setTime(self.maxTime)
	-- self.item:setJobDelta(0.0);
	-- if self.action then
    --     self.action:stopTimedActionAnim();
    -- end

	-- self.action:forceComplete()

	-- --ISBaseTimedAction.perform(self);
end

function PI2ABInventoryTransferAction:perform()
	ISInventoryTransferAction.perform(self)


-- 	-- I would have done this in start(), however the first action added to the queue
-- 	-- is started immediately, before any other actions can be added.
-- 	self:checkQueueList()

-- 	self.item:setJobDelta(0.0)
-- --	print("perform on item", self.item, self.item:getDisplayName())
-- 	-- take the next item in our queue list
-- 	local queuedItem = table.remove(self.queueList, 1);
-- 	-- reopen the correct container
-- 	if self.selectedContainer then
-- 		getPlayerLoot(self.character:getPlayerNum()):selectButtonForContainer(self.selectedContainer)
-- 	end

-- 	if queuedItem ~= nil then
-- 		for i,item in ipairs(queuedItem.items) do
-- 			self.item = item
-- 			-- Check destination container capacity and item-count limit.
-- 			if not self:isValid() then
-- 				self.queueList = {}
-- 				break
-- 			end
-- 			self:transferItem(item);
-- 		end
-- 	end
-- 	-- if we still have other item to transfer in our queue list, we "reset" the action
-- 	if #self.queueList > 0 then
-- 		queuedItem = self.queueList[1]
-- 		self.item = queuedItem.items[1];
-- --		print("reset with new item: ", queuedItem.items[1], #queuedItem.items)
-- 		local time = queuedItem.time;
-- 		if self:isAlreadyTransferred(self.item) then
-- 			time = 0
-- 		end
-- 		if self.allowMissingItems and not self.srcContainer:contains(self.item) then
-- 			time = 0
-- 		end
-- 		if isClient() then
-- 		    self.action:reset() -- set forceComplete=false
-- 		end
-- 		self.maxTime = time
-- 		self.action:setTime(tonumber(time))
-- 		self:resetJobDelta();
-- 		self:startActionAnim()
-- 		self.transactionId = createItemTransaction(self.character, self.item, self.srcContainer, self.destContainer)
-- 	else
-- 		self:playSourceContainerCloseSound()
-- 		self:playDestContainerCloseSound()
-- 	    self:stopLoopingSound()

-- 		self.action:stopTimedActionAnim();
-- 		self.action:setLoopedAction(false);
-- 		if isClient() then
-- 		    self.action:setWaitForFinished(false)
-- 		end

-- 		if self.onCompleteFunc then
-- 			local args = self.onCompleteArgs
-- 			self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
-- 		end

-- 		-- needed to remove from queue / start next.
-- 		ISBaseTimedAction.perform(self);
-- 		self.started = false
-- 	end

-- 	if instanceof(self.item, "Radio") then
-- 		self.character:updateEquippedRadioFreq();
-- 	end
end

function PI2ABInventoryTransferAction:new (character, item, srcContainer, destContainer, time)
	local o = ISInventoryTransferAction.new(self,character, item, srcContainer, destContainer, time)

	return o
end


function PI2ABInventoryTransferAction.create(character, item, srcContainer, destContainer, time)
    local isGrabbingCorpseItem = ISInventoryTransferUtil.isCharacterGrabbingCorpseItem(character, item, srcContainer, destContainer)
    if isGrabbingCorpseItem then
        return ISGrabCorpseItem:new(character, item)
    end

    return PI2ABInventoryTransferAction:new(character, item, srcContainer, destContainer, time)
end