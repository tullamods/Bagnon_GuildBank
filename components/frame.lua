--[[
	frame.lua
		A specialized version of the bagnon frame for guild banks
--]]

local MODULE, Module =  ...
local Addon = Module.Addon
local Frame = Addon:NewClass('GuildFrame', 'Frame', Addon.Frame)

Frame.Title = LibStub('AceLocale-3.0'):GetLocale(Module.ADDON).GuildTitle
Frame.MoneyFrame = Addon.GuildMoneyFrame
Frame.ItemFrame = Addon.GuildItemFrame
Frame.BagFrame = Addon.GuildTabFrame
Frame.CloseSound = 'GuildVaultClose'
Frame.OpenSound = 'GuildVaultOpen'
Frame.Bags = {}

for i = 1, MAX_GUILDBANK_TABS do
	Frame.Bags[i] = i
end


--[[ Constructor ]]--

function Frame:New(id)
	local f = Addon.Frame.New(self, id)

	local log = Addon.LogFrame:New(f)
	log:SetPoint('BOTTOMRIGHT', f.itemFrame, -27, 5)
	log:SetPoint('TOPLEFT', f.itemFrame, 5, -5)

	local edit = Addon.EditFrame:New(f)
	edit:SetAllPoints(log)

	f.logToggles = Addon.LogToggle:NewSet(f)
	f.log, f.editFrame = log, edit
end

function Frame:RegisterMessages()
	Addon.Frame.RegisterMessages(self)
	self:RegisterFrameMessage('SHOW_LOG', 'OnLog')
end


--[[ Events ]]--

function Frame:OnHide()
	Addon.Frame.OnHide(self)

	StaticPopup_Hide('GUILDBANK_WITHDRAW')
	StaticPopup_Hide('GUILDBANK_DEPOSIT')
	StaticPopup_Hide('CONFIRM_BUY_GUILDBANK_TAB')
	CloseGuildBankFrame()
end

function Frame:OnLog(_, logID)
	self.itemFrame:SetShown(not logID)
	self.editFrame:SetShown(logID == 3)
	self.log:SetShown(logID and logID < 3)
end


--[[ Proprieties ]]--

function Frame:AddSpecificButtons(buttonList)
	for i, toggle in ipairs(self.logToggles) do
		tinsert(buttonList, toggle)
	end
end

function Frame:IsCached()
	return Addon:IsBagCached(self:GetPlayer(), 'guild1')
end

function Frame:HasBagFrame()
	return true
end

function Frame:IsBagFrameShown()
	return true
end

function Frame:HasPlayerSelector()
	return false
end
