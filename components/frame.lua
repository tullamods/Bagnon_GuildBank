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


--[[ Interaction ]]--

function Frame:ShowPanel(kind)
	self:FadeOutFrame(self.itemFrame)
	self:FadeOutFrame(self.logFrame)
	self:FadeOutFrame(self.editFrame)

	if not kind then
		self:FadeInFrame(self.itemFrame)
	elseif kind == 3 then
		self:FadeInFrame(self.editFrame or self:CreateEditFrame())
	else
		self:CreateLogFrame():Display(kind)
		self:FadeInFrame(self.logFrame)
	end

	for i, log in ipairs(self.logs) do
		log:SetChecked(kind == i)
	end
end

function Frame:OnHide()
	Addon.Frame.OnHide(self)

	StaticPopup_Hide('GUILDBANK_WITHDRAW')
	StaticPopup_Hide('GUILDBANK_DEPOSIT')
	StaticPopup_Hide('CONFIRM_BUY_GUILDBANK_TAB')
	CloseGuildBankFrame()
end


--[[ Components ]]--

function Frame:GetSpecificButtons(list)
	for i, log in ipairs(self.logs or self:CreateSpecificButtons()) do
		tinsert(list, log)
	end
end

function Frame:CreateSpecificButtons()
	self.logs = {}

	for i = 1, #Addon.LogToggle.Icons do
		self.logs[i] = Addon.LogToggle:New(self, i)
	end

	return self.logs
end

function Frame:CreateLogFrame()
	local log = Addon.LogFrame:New(self)
	log:SetPoint('BOTTOMRIGHT', self.itemFrame, -27, 5)
	log:SetPoint('TOPLEFT', self.itemFrame, 5, -5)

	self.logFrame = log
	return log
end

function Frame:CreateEditFrame()
	local edit = Addon.EditFrame:New(self)
	edit:SetPoint('BOTTOMRIGHT', self.itemFrame, -27, 5)
	edit:SetPoint('TOPLEFT', self.itemFrame, 5, -5)

	self.editFrame = edit
	return edit
end


--[[ Proprieties ]]--

function Frame:HasBagFrame()
	return true
end

function Frame:IsBagFrameShown()
	return true
end

function Frame:HasPlayerSelector()
	return false
end

function Frame:IsCached()
	return Addon:IsBagCached(self:GetPlayer(), 'guild1')
end
