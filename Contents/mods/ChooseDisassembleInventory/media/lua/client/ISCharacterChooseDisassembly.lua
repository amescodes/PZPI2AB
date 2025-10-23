require "ISUI/ISPanelJoypad"
require "ChooseDisassemblyInventoryUtil"

ISCharacterChooseDisassembly = ISPanelJoypad:derive("ISCharacterChooseDisassembly")

local SMALL_FONT_HGT = getTextManager():getFontHeight(UIFont.Small)
local MEDIUM_FONT_HGT = getTextManager():getFontHeight(UIFont.Medium)

function ISCharacterChooseDisassembly:initialise()
    ChooseDisassemblyInventoryUtil.Print("ISCharacterChooseDisassembly:initialise", false)
    ChooseDisassemblyInventory.init()
    ISPanelJoypad.initialise(self)
end

local function addComboOption(combo,name,previousWidth,data)
    local txt = getText(name)
    local txtWidth = getTextManager():MeasureStringX(UIFont.Small, txt)
    combo:addOptionWithData(txt,data)
    if previousWidth > txtWidth then return previousWidth end
    return txtWidth
end

function ISCharacterChooseDisassembly:createChildren()
    ChooseDisassemblyInventoryUtil.Print("ISCharacterChooseDisassembly:createChildren")

    self.textY = 10
    self.inputX = self:getWidth() / 2

    -- OPTIONS LABEL
    if self.optionsLabel then self:removeChild(self.optionsLabel) end
    self.optionsLabel = ISLabel:new(self.textX, self.textY, MEDIUM_FONT_HGT, getText("UI_ChooseDisassemblyInventoryOptions"), 1, 1, 1, 1, UIFont.Medium, true)
	self.optionsLabel:initialise()
	self.optionsLabel:instantiate()
	self:addChild(self.optionsLabel)

    self.textY = self.optionsLabel:getBottom() + 10

    self:createTickBox("Enabled", "UI_char_ChooseDisassemblyInventory_Enabled", "UI_char_ChooseDisassemblyInventory_Enabled_tooltip",
        self.onTickChange)

    self.textY = self.textY + 10

    local comboHgt = SMALL_FONT_HGT + 3 * 2

    -- DEFAULT DESTINATION CONTAINER
    if self.defaultDestContainerLabel then self:removeChild(self.defaultDestContainerLabel) end
    self.defaultDestContainerLabel = ISLabel:new(self.textX, self.textY, SMALL_FONT_HGT, getText("UI_char_ChooseDisassemblyInventory_DestContainer"), 1, 1, 1, 1, UIFont.Small, true)
	self.defaultDestContainerLabel:initialise()
	self.defaultDestContainerLabel:instantiate()
    self.defaultDestContainerLabel.tooltip = getText("UI_char_ChooseDisassemblyInventory_DestContainer_tooltip")
	self:addChild(self.defaultDestContainerLabel)
    
    local minXSecondColumn = self.textX + self.defaultDestContainerLabel:getWidth() + 10
    if self.inputX < minXSecondColumn then
        self.inputX = minXSecondColumn
    end
    
	self.defaultDestContainerCombo = ISComboBox:new(self.inputX, self.textY-2, self.width, comboHgt, self, self.onSettingChange,"DefaultDestinationContainer")
	self.defaultDestContainerCombo:initialise()
	self:addChild(self.defaultDestContainerCombo)

    local width = 0
    width = addComboOption(self.defaultDestContainerCombo,"UI_char_ChooseDisassemblyInventory_DestContainer_PlayerInventory",width,1)
    width = addComboOption(self.defaultDestContainerCombo,"UI_char_ChooseDisassemblyInventory_DestContainer_ItemSource",width,2)
    self.defaultDestContainerCombo:setWidth(width+35)

    self.defaultDestContainerCombo.selected = 1
	if self.char:getModData().ChooseDisassemblyInventory.DefaultDestinationContainer then
        self.defaultDestContainerCombo.selected = ChooseDisassemblyInventory.DefaultDestinationContainer
    end

    self.textY = self.textY + comboHgt + 10

    -- TRANSFER ITEMS
    if self.transferItemsLabel then self:removeChild(self.transferItemsLabel) end
    self.transferItemsLabel = ISLabel:new(self.textX, self.textY-2, SMALL_FONT_HGT, getText("UI_char_ChooseDisassemblyInventory_WhenToTransferItems"), 1, 1, 1, 1, UIFont.Small, true)
	self.transferItemsLabel:initialise()
	self.transferItemsLabel:instantiate()
    self.transferItemsLabel.tooltip = getText("UI_char_ChooseDisassemblyInventory_WhenToTransferItems_tooltip")
	self:addChild(self.transferItemsLabel)
    
	self.transferItemsCombo = ISComboBox:new(self.inputX, self.textY, self.width, comboHgt, self, self.onSettingChange,"WhenToTransferItems")
	self.transferItemsCombo:initialise()
	self:addChild(self.transferItemsCombo)

    width = 0
    width = addComboOption(self.transferItemsCombo,"UI_char_ChooseDisassemblyInventory_WhenToTransferItems_AfterEach",width,1)
    width = addComboOption(self.transferItemsCombo,"UI_char_ChooseDisassemblyInventory_WhenToTransferItems_AtEnd",width,2)
    self.transferItemsCombo:setWidth(width+35)

    self.transferItemsCombo.selected = 1
	if self.char:getModData().ChooseDisassemblyInventory.WhenToTransferItems then
        self.transferItemsCombo.selected = ChooseDisassemblyInventory.WhenToTransferItems
    end

    self.textY = self.textY + 35
end

function ISCharacterChooseDisassembly:render()
    if not self.char:getModData() then
        self:clearStencilRect()
        return
    end

    local tabHeight = self.y
    local maxHeight = getCore():getScreenHeight() - tabHeight - 20
    if ISWindow and ISWindow.TitleBarHeight then
        maxHeight = maxHeight - ISWindow.TitleBarHeight
    end

    local h = self.textY + SMALL_FONT_HGT
    local finalHeight = math.min(h, maxHeight)
    self:setHeightAndParentHeight(finalHeight)
    self:setScrollHeight(h)
end

function ISCharacterChooseDisassembly:onSettingChange(combo, settingId)
    ChooseDisassemblyInventory[settingId] = combo.selected
    self.char:getModData().ChooseDisassemblyInventory[settingId] = ChooseDisassemblyInventory[settingId]
end

function ISCharacterChooseDisassembly:onTickChange(index, enabled, settingId)
    ChooseDisassemblyInventory[settingId] = enabled
    self.char:getModData().ChooseDisassemblyInventory[settingId] = ChooseDisassemblyInventory[settingId]
end

function ISCharacterChooseDisassembly:createTickBox(settingId, text, tooltip, onTickChange)
    local txtWidth = getTextManager():MeasureStringX(UIFont.Medium, getText(text))
    local tickBoxHeight = getTextManager():getFontHeight(UIFont.Medium)
    local viewID = "tickbox_" .. settingId
    if self[viewID] then
        self:removeChild(self[settingId])
    end
    self[viewID] = ISTickBox:new(self.textX, self.textY, txtWidth, tickBoxHeight, viewID, self, onTickChange, settingId)
    self[viewID]:initialise()
    self:addChild(self[viewID])
    self[viewID]:addOption(getText(text))
    self[viewID]:setSelected(1, ChooseDisassemblyInventory[settingId])
    self[viewID].tooltip = getText(tooltip)

    self.textY = self[viewID]:getBottom()
end

function ISCharacterChooseDisassembly:new(x, y, width, height, playerNum)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.char = getSpecificPlayer(playerNum)
    o:noBackground()
    o.textX = 20
    o.inputX = 300
    o.textY = 0

    return o
end
