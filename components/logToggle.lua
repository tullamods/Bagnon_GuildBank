--[[
	logToggle.lua
		A guild log toggle widget
--]]

local MODULE, Module =  ...
local ADDON, Addon = Module.ADDON, Module.Addon
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON)
local LogToggle = Addon:NewClass('LogToggle', 'CheckButton')

LogToggle.Icons = {
	[[Interface\Icons\INV_Crate_03]],
	[[Interface\Icons\INV_Misc_Coin_01]],
	[[Interface\Icons\INV_Letter_20]]
}

LogToggle.Titles = {
	GUILD_BANK_LOG,
	GUILD_BANK_MONEY_LOG,
	GUILD_BANK_TAB_INFO
}


--[[ Constructors ]]--

function LogToggle:NewSet(parent)
	local set = {}
	for id in ipairs(self.Icons) do
		set[id] = self:New(parent, id)
	end
	return set
end

function LogToggle:New(parent, id)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent, ADDON..'MenuCheckButtonTemplate'))
	b.Icon:SetTexture(self.Icons[id])
	b:RegisterFrameMessage('SHOW_LOG', 'OnLog')
	b:SetScript('OnClick', b.OnClick)
	b.id = id

	return b
end


--[[ Events ]]--

function LogToggle:OnLog(_, logID)
	self:SetChecked(logID == self.id)
end

function LogToggle:OnClick()
	self:SendFrameMessage('SHOW_LOG', self:GetChecked() and self.id)
end

function LogToggle:OnEnter()
	GameTooltip:SetOwner ...
	GameTooltip:SetText(self.Titles[self.id]))
	GameTooltip:Show()
end
