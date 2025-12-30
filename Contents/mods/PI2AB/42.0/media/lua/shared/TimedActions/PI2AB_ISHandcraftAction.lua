local old_ISHandcraftAction_forceStop = ISHandcraftAction.forceStop
function ISHandcraftAction:forceStop()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
    old_ISHandcraftAction_forceStop(self);
end

local old_ISHandcraftAction_forceCancel = ISHandcraftAction.forceCancel
function ISHandcraftAction:forceCancel()
	if self.pi2ab_timestamp then PI2ABComparer.remove(self.pi2ab_timestamp) end
	
	old_ISHandcraftAction_forceCancel(self)
end

-- -- completely overwriting perform to add PI2AB functionality
-- function ISHandcraftAction:perform()
-- 	--log(DebugType.CraftLogic, "ISHandcraftAction.perform")

-- 	self:clearItemsProgressBar(false);
	
-- 	if self.sound and self.character:getEmitter():isPlaying(self.sound) then
-- 		self.character:stopOrTriggerSound(self.sound);
-- 	end

-- 	ISInventoryPage.dirtyUI();

-- 	if not isClient() then
-- 		self:performRecipe();
-- 	end
	
-- 	-- spurcival: super.perform() must happen AFTER performRecipe() as super.perform() kicks off the next multicraft.
-- 	ISBaseTimedAction.perform(self);

-- 	if isClient() and self.onCompleteFunc then
-- 		self.onCompleteFunc(self.onCompleteTarget);
-- 	end
-- end

-- -- completely overwriting complete to add PI2AB functionality
-- function ISHandcraftAction:complete()
--     if self.eatPercentage > 0 and self.logic:getRecipeData() then
--         self.logic:getRecipeData():setEatPercentage(self.eatPercentage)
--     end

-- 	self:clearItemsProgressBar(false);

-- 	if isServer() then
-- 		-- spurcival : this has to be completed in perform, or at that same point in time. complete() is too late.
-- 		self:performRecipe();
-- 	end

-- 	if self.onCompleteFunc then
-- 		self.onCompleteFunc(self.onCompleteTarget);
-- 	end
-- 	return true
-- end



function ISHandcraftAction:setPI2ABOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompletePI2ABFunc = func
	self.onCompletePI2ABArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end