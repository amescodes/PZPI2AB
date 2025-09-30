local modName = "ChooseDisassemblyInventory"

local upperLayer_ISCharacterInfoWindow_createChildren = ISCharacterInfoWindow.createChildren
function ISCharacterInfoWindow:createChildren()
    upperLayer_ISCharacterInfoWindow_createChildren(self)

    self.chooseDisassemblyView = ISCharacterChooseDisassembly:new(0, 8, 300, 200, self.playerNum)
    self.chooseDisassemblyView:initialise()
    self.panel:addView(getText("UI_ChooseDisassemblyInventory"), self.chooseDisassemblyView)
end

local upperLayer_ISCharacterInfoWindow_onTabTornOff = ISCharacterInfoWindow.onTabTornOff
function ISCharacterInfoWindow:onTabTornOff(view, window)
    if self.playerNum == 0 and view == self.chooseDisassemblyView then
        ISLayoutManager.RegisterWindow("charinfowindow.ChooseDisassemblyInventory", ISCollapsableWindow, window)
    end
    upperLayer_ISCharacterInfoWindow_onTabTornOff(self, view, window)
end

local upperLayer_ISCharacterInfoWindow_SaveLayout = ISCharacterInfoWindow.SaveLayout
function ISCharacterInfoWindow:SaveLayout(name, layout)
    upperLayer_ISCharacterInfoWindow_SaveLayout(self, name, layout)

    local addTabName = false
    local subSelf = self.trackItemsView
    if subSelf and subSelf.parent == self.panel then
        addTabName = true
        if subSelf == self.panel:getActiveView() then
            layout.current = modName
        end
    end
    if addTabName then
        if not layout.tabs then
            layout.tabs = modName
        else
            layout.tabs = layout.tabs..","..modName
        end
    end
end