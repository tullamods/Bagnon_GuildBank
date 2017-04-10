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


--[[ Button ]]--

function LogToggle:New(parent, type)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent, ADDON..'MenuCheckButtonTemplate'))
	b.Icon:SetTexture(self.Icons[type])
	b:RegisterFrameMessage('SHOW_LOG', 'OnLog')
	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnHide', b.OnHide)
	b.type = type

	return b
end

function LogToggle:OnLog(_, type)
	self:SetChecked(type == self.type)
end

function LogToggle:OnClick()
	self:SendFrameMessage('SHOW_LOG', self:GetChecked() and self.type)
end

function LogToggle:OnHide()
	self:SendFrameMessage('SHOW_LOG', nil)
end

function LogToggle:OnTooltip()
	GameTooltip:SetText(self.Titles[type]))
end
