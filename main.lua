--[[
	main.lua
		Show and hide frame
--]]

local MODULE, Module =  ...
Module.ADDON = MODULE:find('^(%w)_')
Module.Addon = _G[Module.ADDON]

local Addon = Module.Addon
local GuildBank = Addon:NewModule('GuildBank', Addon)

function GuildBank:OnEnable()
	self:RegisterEvent('GUILDBANKFRAME_CLOSED', 'OnClose')
end

function GuildBank:OnOpen()
	Addon.Cache.AtGuild = true
	Addon:ShowFrame('guild')
	QueryGuildBankTab(GetCurrentGuildBankTab())
end

function GuildBank:OnClose()
	Addon.Cache.AtGuild = nil
	Addon:HideFrame('guild')
end
