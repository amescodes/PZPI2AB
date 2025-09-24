require "ISBaseTimedAction"

ChooseDisassemblyInventory_CheckInventory = ISBaseTimedAction:derive("ChooseDisassemblyInventory_CheckInventory");

function ChooseDisassemblyInventory_CheckInventory:isValid()
    return true
end

function ChooseDisassemblyInventory_CheckInventory:perform()
    local res = self.recipe:getResult()
    local cont = self.selectedItemContainer
    if res then
        local resItemType = res:getFullType()
        local count = res:getCount()
        local playerInv = self.character:getInventory()
        if playerInv:containsType(resItemType) then
            for _=1,count do
                local it = playerInv:FindAndReturn(resItemType)
                if it then
                    local action = ISInventoryTransferAction:new(self.character, it, playerInv, self.selectedItemContainer, nil)
                    
                    action:setAllowMissingItems(true)
                    ISTimedActionQueue.add(action)
                    local test = self.character:getCharacterActions():contains(action)
                end
            end
        end
    end

    ISBaseTimedAction.perform(self);
end

function ChooseDisassemblyInventory_CheckInventory:new(character,selectedItemContainer,recipe)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.stopOnAim = true;
    o.caloriesModifier = 1;
	o.maxTime = 0;
    o.selectedItemContainer = selectedItemContainer
    o.recipe = recipe
	return o
end
