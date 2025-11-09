local old_ISInventoryPage_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
    local page = self.parent
	local container = self.inventory
	local item = container:getContainingItem()
    if not item then
        local context = ISInventoryPaneContextMenu.createMenuNoItems(page.player, (not page.onCharacter), getMouseX(), getMouseY())
		if context and context.numOptions >= 1 then
			context.origin = page
			context.mouseOver = 1
			setJoypadFocus(page.player, context)
            return
		end
    end

    old_ISInventoryPage_onBackpackRightMouseDown(self,x,y)
end