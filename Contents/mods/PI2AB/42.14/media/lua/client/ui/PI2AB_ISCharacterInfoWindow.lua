local modName = "PI2AB"

local upperLayer_ISCharacterInfoWindow_createChildren = ISCharacterInfoWindow.createChildren
function ISCharacterInfoWindow:createChildren()
    upperLayer_ISCharacterInfoWindow_createChildren(self)

    self.PI2ABView = ISCharacterPI2AB:new(0, 8, 350, 200, self.playerNum)
    self.PI2ABView:initialise()
    self.panel:addView(getText("UI_PI2AB"), self.PI2ABView)
end

local upperLayer_ISCharacterInfoWindow_onTabTornOff = ISCharacterInfoWindow.onTabTornOff
function ISCharacterInfoWindow:onTabTornOff(view, window)
    if self.playerNum == 0 and view == self.PI2ABView then
        ISLayoutManager.RegisterWindow("charinfowindow.PI2AB", ISCollapsableWindow, window)
    end
    upperLayer_ISCharacterInfoWindow_onTabTornOff(self, view, window)
end

local upperLayer_ISCharacterInfoWindow_SaveLayout = ISCharacterInfoWindow.SaveLayout
function ISCharacterInfoWindow:SaveLayout(name, layout)
    upperLayer_ISCharacterInfoWindow_SaveLayout(self, name, layout)

    local addTabName = false
    local subSelf = self.PI2ABView
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