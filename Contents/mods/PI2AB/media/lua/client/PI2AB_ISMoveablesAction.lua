function ISMoveablesAction:perform()
    if self.mode and self.mode=="scrap" then
		self.moveProps.object:setHighlighted(false);
	end
    if self.sound and self.sound ~= 0 then
        self.character:stopOrTriggerSound(self.sound);
    end

    if self.moveProps and self.moveProps.isMoveable and self.mode and self.mode ~= "scrap" then
        self.moveProps.cursorFacing = self.cursorFacing
        if self.mode == "pickup" then
            self.moveProps:pickUpMoveableViaCursor( self.character, self.square, self.origSpriteName, self.moveCursor ); --OrigSpriteName currently not used in this one.
        elseif self.mode == "place" then
            self.moveProps:placeMoveableViaCursor( self.character, self.square, self.origSpriteName, self.moveCursor );
            buildUtil.setHaveConstruction(self.square, true);
        elseif self.mode == "rotate" then
            self.moveProps:rotateMoveableViaCursor( self.character, self.square, self.origSpriteName, self.moveCursor );
        end
        self.moveProps.cursorFacing = nil
    elseif self.mode and self.mode=="scrap" then
        self.moveProps:scrapObjectViaCursor( self.character, self.square, self.origSpriteName, self.moveCursor );
    end

    -- NEW FOR PI2AB
	if self.onCompleteFunc then
		local args = self.onCompleteArgs
		self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
	end

    ISBaseTimedAction.perform(self)
end


function ISMoveablesAction:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end